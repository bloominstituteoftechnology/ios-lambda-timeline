//
//  AudioCommentTableViewCell.swift
//  AudioComments
//
//  Created by Christian Lorenzo on 5/12/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

class AudioCommentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var timePassed: UILabel!
    @IBOutlet weak var playButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        timeLeft.font = UIFont.monospacedDigitSystemFont(ofSize: timeLeft.font.pointSize, weight: .regular)
        timePassed.font = UIFont.monospacedDigitSystemFont(ofSize: timePassed.font.pointSize, weight: .regular)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
