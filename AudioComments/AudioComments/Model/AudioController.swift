//
//  AudioPlayerController.swift
//  AudioComments
//
//  Created by David Wright on 5/11/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioRecorderDelegate: class {
    func didSendAudioRecording(_ audioComment: AudioComment)
    func updateAudioPlayerViews()
}

class AudioPlayerController: UIViewController {
    
    // MARK: - Properties
    
    private var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            updateViews()
        }
    }
    
    private var elapsedTime: TimeInterval { audioPlayer?.currentTime ?? 0 }
    private var duration: TimeInterval { audioPlayer?.duration ?? 0 }
    private var timeRemaining: TimeInterval { duration.rounded() - elapsedTime }
    
    private var recordingURL: URL?
    weak var delegate: AudioRecorderDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeSlider.value = 0
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                                 weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
    }
    
    /// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("wav")
        return fileURL
    }
    
    func loadAudio(from data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
        } catch {
            preconditionFailure("Failure to load audio file: \(error)")
        }
    }
    
    func loadAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            preconditionFailure("Failure to load audio file: \(error)")
        }
    }
    
    // MARK: - IBActions
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func updateCurrentTime(time: TimeInterval) {
        if isPlaying {
            pause()
        }
        
        audioPlayer?.currentTime = time
        updateViews()
    }
    
    func rewindCurrentTimeBy(seconds: TimeInterval) {
        let newTime = elapsedTime - seconds
        
        if newTime < 0 {
            updateCurrentTime(time: 0)
        } else {
            updateCurrentTime(time: newTime)
        }
    }
    
    func skipForwardCurrentTimeBy(seconds: TimeInterval) {
        let newTime = elapsedTime + seconds
        
        if newTime > duration {
            updateCurrentTime(time: duration)
        } else {
            updateCurrentTime(time: newTime)
        }
    }
    
    // MARK: - Update Views
    
    private func updateViews() {
        playButton.isSelected = isPlaying
        
        timeElapsedLabel.text = Formatter.string(from: elapsedTime)
        
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(elapsedTime)
        
        timeRemainingLabel.text = "-" + Formatter.string(from: timeRemaining)
    }
    
    // MARK: - Timer
    
    private weak var timer: Timer?
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
            
            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {
                
                audioPlayer.updateMeters()
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
}


// MARK: - AVAudioPlayerDelegate

extension AudioPlayerController: AVAudioPlayerDelegate {
    
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
