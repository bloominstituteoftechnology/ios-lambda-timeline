//
//  AudioCommentTableViewCell.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/10/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet var elapsedTimeLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    
    //MARK: - Properties
    var timer: Timer?
    var recordingURL: URL? {
        didSet {
            setAudioPlayer()
        }
    }
    
    let audioPlayerController = AudioPlayerController()
    var timeIntervalFormatter: DateComponentsFormatter?
    
    // MARK: - IBActions
    @IBAction func togglePlayback(_ sender: UIButton) {
        audioPlayerController.togglePlayback()
        updateViews()
        
        switch playButton.isSelected {
        case true:
            startTimer()
        default:
            cancelTimer()
        }
    }
    // MARK: - Functions
    func updateViews() {
        playButton.isSelected = audioPlayerController.audioPlayer?.isPlaying ?? false

        let duration = audioPlayerController.audioPlayer?.duration ?? 0
        let elapsedTime = audioPlayerController.audioPlayer?.currentTime ?? 0
        let timeRemaining = round(duration) - elapsedTime

        elapsedTimeLabel.text = timeIntervalFormatter?.string(from: elapsedTime)
        durationLabel.text = timeIntervalFormatter?.string(from: timeRemaining)

        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(elapsedTime)
    }
    func setAudioPlayer() {
        guard let recordingURL = recordingURL else { return }
        
        do {
            audioPlayerController.audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
        } catch {
            print("Error setting audio player: \(error)")
            return
        }
        
        updateViews()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true, block: { [weak self]  _ in
            guard let self = self else { return }
            
            self.updateViews()
        })
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

}

//MARK: - Extension
extension AudioCommentTableViewCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        cancelTimer()
        updateViews()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error during playback: \(error)")
        }

        cancelTimer()
        updateViews()
    }
}
