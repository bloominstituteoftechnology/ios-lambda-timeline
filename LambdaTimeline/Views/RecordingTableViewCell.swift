//
//  RecordingTableViewCell.swift
//  LambdaTimeline
//
//  Created by Conner on 10/16/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {
    
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func playRecordingButtonTapped(_ sender: Any) {
    }
}
