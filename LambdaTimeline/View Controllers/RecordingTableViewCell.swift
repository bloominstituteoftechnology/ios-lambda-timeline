//
//  RecordingTableViewCell.swift
//  LambdaTimeline
//
//  Created by Dennis Rudolph on 1/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {

    @IBOutlet weak var recordingNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var comment: Comment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
