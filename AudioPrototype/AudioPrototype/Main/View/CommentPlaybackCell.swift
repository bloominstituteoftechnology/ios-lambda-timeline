//
//  CommentRecorderTableViewCell.swift
//  AudioPrototype
//
//  Created by Kenny on 6/2/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit
import AVFoundation

class CommentPlaybackCell: UITableViewCell {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!

    ///lazy in order to ensure self is available
    private lazy var audioPlayer = AudioPlayer(delegate: self)
    var recordedURL: URL? {
        didSet {
            updateViews()
        }
    }

    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)

        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    override func prepareForReuse() {
        loadView()
    }

    private func loadView() {
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(
            ofSize: timeElapsedLabel.font.pointSize,
            weight: .regular
        )
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(
            ofSize: timeRemainingLabel.font.pointSize,
            weight: .regular
        )
    }

    private func updateViews() {
        playButton.isSelected = audioPlayer.isPlaying
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
}

extension CommentPlaybackCell: AudioPlayerUIDelegate {
    func updateUI() {
        updateViews()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print(error)
        }
    }
}
