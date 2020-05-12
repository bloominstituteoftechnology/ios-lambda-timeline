//
//  AudioRecorderController.swift
//  AudioComments
//
//  Created by David Wright on 5/10/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioRecorderControllerDelegate: class {
    func didSendAudioRecording(_ audioComment: AudioComment)
}

class AudioRecorderController: UIViewController {
    
    // MARK: - Properties

    private var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            updateViews()
        }
    }
    
    private var recordingURL: URL?
    private var audioRecorder: AVAudioRecorder?
    private var didSaveRecordingToDisk: Bool = false
    
    weak var delegate: AudioRecorderControllerDelegate?
    
    
    // MARK: - IBOutlets
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var audioVisualizer: AudioVisualizer!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeSlider.value = 0
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                                 weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
    }
    
    // MARK: - IBActions
    
    @IBAction func togglePlayback(_ sender: UIButton) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        if isPlaying {
            pause()
        }
        
        audioPlayer?.currentTime = TimeInterval(sender.value)
        updateViews()
    }
    
    @IBAction func toggleRecording(_ sender: UIButton) {
        if isRecording {
            stopRecording()
        } else {
            requestPermissionOrStartRecording()
        }
    }
    
    @IBAction func cancelRecording(_ sender: UIBarButtonItem) {
        cancelTimer()
        if didSaveRecordingToDisk, let url = recordingURL {
            deleteRecording(at: url)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendRecording(_ sender: UIBarButtonItem) {
        guard let audioPlayer = audioPlayer, audioPlayer.duration > 0,
        let url = recordingURL else { return }
        
        cancelTimer()
        
        let audioComment = AudioComment(title: "New Audio Comment", duration: audioPlayer.duration, url: url)
        delegate?.didSendAudioRecording(audioComment)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Update Views
    
    private func updateViews() {
        //
        playButton.isEnabled = !isRecording
        recordButton.isEnabled = !isPlaying
        timeSlider.isEnabled = !isRecording
        
        playButton.isSelected = isPlaying
        recordButton.isSelected = isRecording
        
        if !isRecording {
            let elapsedTime = audioPlayer?.currentTime ?? 0
            let duration = audioPlayer?.duration ?? 0
            let timeRemaining = duration.rounded() - elapsedTime
            
            timeElapsedLabel.text = Formatter.string(from: elapsedTime)
            
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = Float(duration)
            timeSlider.value = Float(elapsedTime)
            
            timeRemainingLabel.text = "-" + Formatter.string(from: timeRemaining)
        } else {
            let elapsedTime = audioRecorder?.currentTime ?? 0
            
            timeElapsedLabel.text = "--:--"
            
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = 1
            timeSlider.value = 0
            
            timeRemainingLabel.text = Formatter.string(from: elapsedTime)
        }
    }
    
    // MARK: - Timer
    
    private weak var timer: Timer?
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
            
            if let audioRecorder = self.audioRecorder,
                self.isRecording == true {

                audioRecorder.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioRecorder.averagePower(forChannel: 0))
            }

            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {

                audioPlayer.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
            }
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Playback
    
    private var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    private func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    private func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            updateViews()
            startTimer()
        } catch {
            print("Cannot play audio: \(error)") // TODO: display an alert to the user here
        }
    }
    
    private func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    // MARK: - Recording
    
    private var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    private func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(file)")
        
        didSaveRecordingToDisk = false
        
        return file
    }
    
    private func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")
            
            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    
    private func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Cannot record audio: \(error)")
            return
        }
        
        recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            updateViews()
            startTimer()
        } catch {
            preconditionFailure("The audio recorder could not be created with \(recordingURL!) and \(format)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        updateViews()
        cancelTimer()
    }
    
    private func deleteRecording(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Could not delete recording with URL: \(url)")
        }
    }
}


// MARK: - AVAudioPlayerDelegate

extension AudioRecorderController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        cancelTimer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}


// MARK: - AVAudioRecorderDelegate

extension AudioRecorderController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
        }
        audioRecorder = nil
        didSaveRecordingToDisk = true
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}
