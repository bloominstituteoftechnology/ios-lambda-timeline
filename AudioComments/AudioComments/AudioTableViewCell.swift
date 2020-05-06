//
//  AudioTableViewCell.swift
//  AudioComments
//
//  Created by Mark Gerrior on 5/5/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
//

import UIKit

class AudioTableViewCell: UITableViewCell {

    // MARK: - Properties
    var recording: Recording? = nil {
        didSet {
            updateViews()
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var playPauseRecordStopButtonLabel: UIButton!

    // MARK: - Actions
    @IBAction func audioSlider(_ sender: Any) {
    }

    @IBAction func shareButton(_ sender: UIButton) {
    }

    @IBAction func backButton(_ sender: UIButton) {
    }

    @IBAction func playPauseRecordStopButton(_ sender: UIButton) {
    }

    @IBAction func forwardButton(_ sender: UIButton) {
    }

    @IBAction func deleteButton(_ sender: UIButton) {
    }

    func updateViews() {
        guard let recording = recording else { return }

        // Handle state of Play/Pause, Record/Stop button.
        if recording.filename == nil {
            playPauseRecordStopButtonLabel.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            playPauseRecordStopButtonLabel.setImage(UIImage(systemName: "stop.fill"), for: .selected)
        } else {
            playPauseRecordStopButtonLabel.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playPauseRecordStopButtonLabel.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        }
    }
}
