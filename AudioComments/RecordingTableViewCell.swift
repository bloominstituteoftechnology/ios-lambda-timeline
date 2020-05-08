//
//  RecordingTableViewCell.swift
//  AudioComments
//
//  Created by Tobi Kuyoro on 06/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var recordingTitle: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!

    // MARK: - IBActions

    @IBAction func togglePlayback(_ sender: Any) {
    }

    @IBAction func updateCurrentTime(_ sender: Any) {
    }
}
