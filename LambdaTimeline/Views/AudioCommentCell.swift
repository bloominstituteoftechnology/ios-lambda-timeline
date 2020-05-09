//
//  AudioCommentCell.swift
//  LambdaTimeline
//
//  Created by Nick Nguyen on 4/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentCell: UITableViewCell {

    @IBOutlet weak var playButton: UIButton!
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBOutlet weak var authorLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
