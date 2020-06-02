//
//  AudioCommentTableViewCell.swift
//  AudioComments
//
//  Created by Hunter Oppel on 6/2/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentTableViewCell: UITableViewCell {
    var timer: Timer?
    
    var recordingURL: URL? {
        didSet {
            setAudioPlayer()
        }
    }
    
    let audioPlayerController = AudioPlayerController()
    var timeIntervalFormatter: DateComponentsFormatter?
    
    @IBOutlet weak var playButtton: UIButton!
    
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBAction func togglePlayback(_ sender: Any) {
        togglePlayback()
    }
    
    private func togglePlayback() {
        audioPlayerController.togglePlayback()
        updateViews()
        
        switch playButtton.isSelected {
        case true:
            startTimer()
        case false:
            stopTimer()
        }
    }
    
    private func updateViews() {
        playButtton.isSelected = audioPlayerController.audioPlayer?.isPlaying ?? false
        
        let duration = audioPlayerController.audioPlayer?.duration ?? 0
        let elapsedTime = audioPlayerController.audioPlayer?.currentTime ?? 0
        let timeRemaining = round(duration) - elapsedTime
        
        elapsedTimeLabel.text = timeIntervalFormatter?.string(from: elapsedTime)
        timeRemainingLabel.text = timeIntervalFormatter?.string(from: timeRemaining)
        
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(elapsedTime)
    }
    
    private func setAudioPlayer() {
        guard let recordingURL = recordingURL else { return }
        do {
            audioPlayerController.audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
        } catch {
            print("Error setting audio player: \(error)")
            return
        }
        updateViews()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            
            self.updateViews()
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioCommentTableViewCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error during playback: \(error)")
        }
        
        stopTimer()
        updateViews()
    }
}
