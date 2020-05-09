//
//  AudioCommentTableViewCell.swift
//  AudioComments
//
//  Created by Jessie Ann Griffin on 5/8/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentTitle: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var commentDuration: UILabel!
    @IBOutlet weak var commentSlider: UISlider!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    weak var timer: Timer?

    var recordingURL: URL?
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            loadAudio()
        }
    }
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    deinit {
        timer?.invalidate()
    }
    
    func updateViews() {
        commentTitle.text = recordingURL?.absoluteString

        commentSlider.isEnabled = isPlaying
        playButton.isSelected = isPlaying
        if isPlaying {
            let elapsedTime = audioPlayer?.currentTime ?? 0
            let duration = audioPlayer?.duration ?? 0
            let timeRemaining = duration.rounded() - elapsedTime
            timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
            commentSlider.minimumValue = 0
            commentSlider.maximumValue = Float(duration)
            commentSlider.value = Float(elapsedTime)
            timeRemainingLabel.text = "-" + timeIntervalFormatter.string(from: timeRemaining)!
        }
    }
    
        // MARK: - Timer
        
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
            
            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {
                audioPlayer.updateMeters()
//                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
            }
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Playback
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func loadAudio() {
        if let recordingURL = recordingURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
            } catch {
                preconditionFailure("Failure to load audio file: \(error)")
            }
        }
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: [])
    }
    
    func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            updateViews()
            startTimer()
        } catch {
            print("Cannot play audio: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    @IBAction func playButtonEnabled(_ sender: Any) {
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
}

extension AudioCommentTableViewCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        cancelTimer()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio player error: \(error)")
        }
    }
}
