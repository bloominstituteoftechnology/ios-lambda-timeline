//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var playStopButton: UIButton!
    var audioURL: URL?
    var player: Player = Player()
    
    @IBAction func playStopButtonClicked(_ sender: Any) {
//        player.play(song: audioURL)
       player.play(song: audioURL)
    }
    
}
