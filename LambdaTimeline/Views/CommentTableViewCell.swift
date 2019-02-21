//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell, PlayerDelegate {
    
    override func awakeFromNib() {
        player.delegate = self
    }

    func playerDidChangeState(_ player: Player) {
        updateViews()
    }
    
    private func updateViews(){
        
        let isPlaying = player.isPlaying
        playStopButton.imageView?.image = isPlaying ? UIImage(named: "stop") : UIImage(named: "circle")

    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var playStopButton: UIButton!
    var audioURL: URL?
    var player: Player = Player()
    
    @IBAction func playStopButtonClicked(_ sender: Any) {
        if player.isPlaying {
            player.stop()
        } else {
            player.play(song: audioURL)
        }
        
    }
    
}
