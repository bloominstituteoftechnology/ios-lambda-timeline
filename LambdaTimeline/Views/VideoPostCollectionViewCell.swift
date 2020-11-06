//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Cora Jacobson on 11/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVKit

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var playerView: VideoPlayerView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var labelBackgroundView: UIView!
    
    lazy private var player = AVPlayer()
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerView = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let post = post,
            case MediaType.video(let videoURL) = post.mediaType else { return }
        titleLabel.text = post.title
        authorLabel.text = post.author
        playMovie(url: videoURL)
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        labelBackgroundView.clipsToBounds = true
    }
    
    func playMovie(url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        
        if playerView == nil {
            playerView = VideoPlayerView()
            playerView.player = player
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playRecording(_:)))
            playerView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBAction func playRecording(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        player.play()
    }
    
}
