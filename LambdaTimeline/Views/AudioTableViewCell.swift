//
//  AudioTableViewCell.swift
//  LambdaTimeline
//
//  Created by Luqmaan Khan on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioTableViewCell: UITableViewCell {

    @IBOutlet var sendersName: UILabel!
    
    @IBOutlet var playRecording: UIButton!
    
    var buttonAction: ((_ sender: AnyObject) -> Void)?
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.buttonAction?(sender)
    }
    
}
