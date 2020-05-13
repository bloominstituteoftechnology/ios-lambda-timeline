//
//  AudioCommentTableViewCell.swift
//  AudioComments
//
//  Created by Alex Thompson on 5/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentTableViewCell: UITableViewCell {
    
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var audioSlider: UISlider!
    @IBOutlet var timeLeft: UILabel!
    @IBOutlet var timePassed: UILabel!
    @IBOutlet var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLeft.font = UIFont.monospacedDigitSystemFont(ofSize: timeLeft.font.pointSize, weight: .regular)
        
        timePassed.font = UIFont.monospacedDigitSystemFont(ofSize: timePassed.font.pointSize, weight: .regular)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
