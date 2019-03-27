//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Angel Buenrostro on 3/27/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CommentTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private var audioPlayer: AVAudioPlayer!
    var audioURL: URL?

    @IBAction func playButtonPressed(_ sender: Any) {
        
        // play audio comment
        
    }
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}
