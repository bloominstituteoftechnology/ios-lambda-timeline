//
//  AudioCommentViewController.swift
//  AudioComments
//
//  Created by Jessie Ann Griffin on 5/8/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    
    weak var timer: Timer?
    
    var recordingURL: URL?
    var audioCommentRecorder: AVAudioRecorder?

    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        
//        loadAudio()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Timer
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
            
            if let audioCommentRecorder = self.audioCommentRecorder,
                self.isRecording == true {

                audioCommentRecorder.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioCommentRecorder.averagePower(forChannel: 0))
            }
//
//            if let audioPlayer = self.audioPlayer,
//                self.isPlaying == true {
//                audioPlayer.updateMeters()
//                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
//            }
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateViews() {
//        playButton.isEnabled = !isRecording
//        recordButton.isEnabled = !isPlaying
        timeSlider.isEnabled = !isRecording
//        playButton.isSelected = isPlaying
        recordButton.isSelected = isRecording
//        if !isRecording {
//            let elapsedTime = audioPlayer?.currentTime ?? 0
//            let duration = audioPlayer?.duration ?? 0
//            let timeRemaining = duration.rounded() - elapsedTime
//            timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
//            timeSlider.minimumValue = 0
//            timeSlider.maximumValue = Float(duration)
//            timeSlider.value = Float(elapsedTime)
//            timeRemainingLabel.text = "-" + timeIntervalFormatter.string(from: timeRemaining)!
//        } else {
        if isRecording {
            let elapsedTime = audioCommentRecorder?.currentTime ?? 0
            timeElapsedLabel.text = "--:--"
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = 1
            timeSlider.value = 0
            timeRemainingLabel.text = timeIntervalFormatter.string(from: elapsedTime)!
        }
    }

    // MARK: - Recording
    
    var isRecording: Bool {
        audioCommentRecorder?.isRecording ?? false
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        print("recording URL: \(file)")

        return file
    }
    
    func requestPermissionOrStartRecording() {
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
    
    func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Cannot record audio: \(error)")
            return
        }
        
        recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        do {
            audioCommentRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioCommentRecorder?.delegate = self
            audioCommentRecorder?.record()
            audioCommentRecorder?.isMeteringEnabled = true
            updateViews()
            startTimer()
        } catch {
            preconditionFailure("The audio recorder could not be created with \(recordingURL!) and \(format)")
        }
    }
    
    func stopRecording() {
        audioCommentRecorder?.stop()
        updateViews()
        cancelTimer()
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    // MARK: - Actions
    @IBAction func toggleRecording(_ sender: Any) {
        if isRecording {
            stopRecording()
        } else {
            requestPermissionOrStartRecording()
        }
    }
    
}

extension AudioCommentViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if let recordingURL = recordingURL {
//            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
//        }
//        audioRecorder = nil
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Recorder error: \(error)")
        }
    }
}
