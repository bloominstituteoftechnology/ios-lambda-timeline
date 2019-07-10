//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Thomas Cacciatore on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    var player: AVPlayer!
    
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
       self.contentView.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    func updateViews() {
        guard let post = post else { return }
        playMovie(url: post.mediaURL)
       
    }

    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
}
