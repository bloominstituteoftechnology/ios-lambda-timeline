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
    var recording: Recording? = nil

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

}
