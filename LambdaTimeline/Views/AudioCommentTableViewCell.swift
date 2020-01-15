//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Jordan Christensen on 11/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var audioSlider: UISlider!
    
    var player: Player!
    
    var audioClip: URL? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        if let audioClip = audioClip {
            player = Player(url: audioClip)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func togglePlay(_ sender: Any) {
        guard let player = player else { return }
        if playButton.image(for: .normal) == UIImage(systemName: "play.fill") {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
        player.playPause()
    }
}
