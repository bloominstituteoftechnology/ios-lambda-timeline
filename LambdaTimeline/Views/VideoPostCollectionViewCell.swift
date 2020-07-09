//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Michael Stoffer on 9/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let post = post else { return }
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
        
        player = AVQueuePlayer(url: post.mediaURL)
        
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = videoPlaybackView.frame
        
        playerLooper = AVPlayerLooper(player: player, templateItem: player.items().first!)
        videoPlaybackView.layer.addSublayer(playerLayer)
        videoPlaybackView.playerLayer = playerLayer
        videoPlaybackView.layer.masksToBounds = true
        player.play()
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        labelBackgroundView.clipsToBounds = true
    }
    
    var playerLayer: AVPlayerLayer!
    var player: AVQueuePlayer!
    var playerLooper: AVPlayerLooper!
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var videoPlaybackView: VideoContainerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    
}
