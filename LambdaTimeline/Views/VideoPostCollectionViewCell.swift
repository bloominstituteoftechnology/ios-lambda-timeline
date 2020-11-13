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
    
    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var labelBackgroundView: UIView!
        
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
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let post = post else { return }
        titleLabel.text = post.title
        authorLabel.text = post.author
        playMovie()
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        labelBackgroundView.clipsToBounds = true
    }
    
    func playMovie() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playRecording(_:)))
        playerView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func playRecording(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended,
              let post = post else { return }
        if case MediaType.video(let videoURL) = post.mediaType {
            playerView.player?.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
            playerView.player?.play()
        }
    }
}
