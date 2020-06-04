//
//  ViewController.swift
//  AudioPrototype
//
//  Created by Kenny on 6/2/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPrototypeViewController: UIViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel
    @IBOutlet weak var timeRemainingLabel: UILabel

    ///lazy in order to ensure self is available
    lazy var audioPlayer = AudioPlayer(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func updateViews() {
        playButton.isSelected = audioPlayer.isPlaying
        //recordButton.isSelected = audioRecorder.isRecording
        let elapsedTime = audioPlayer.player?.currentTime ?? 0
        let duration = audioPlayer.player?.duration ?? 0
        let timeRemaining = duration.rounded(.up) - elapsedTime.rounded(.up)

        timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        timeRemainingLabel.text = timeIntervalFormatter.string(from: timeRemaining)

        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(elapsedTime)
    }

    @IBAction func playButtonWasTapped(_ sender: UIButton) {
        audioPlayer.togglePlaying()
        updateViews()
    }

    @IBAction func recordButtonWasTapped(_ sender: UIButton) {
        //audioRecorder.toggleRecording()
        updateViews()
    }
}

extension AudioPrototypeViewController: AVAudioPlayerDelegate {

}
