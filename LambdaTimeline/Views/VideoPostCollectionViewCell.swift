//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var player: AVPlayer!
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    var isPlaying = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        videoPreviewView.layer.sublayers = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let post = post else { return }
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        //        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
        //        labelBackgroundView.layer.borderWidth = 0.5
        labelBackgroundView.clipsToBounds = true
    }
    @IBAction func playButtonTapped(_ sender: Any) {
        player.seek(to: .zero)
        
        player.play()
    }
    
    func setVideo(_ url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = videoPreviewView.bounds
        videoPreviewView.layer.addSublayer(playerLayer)
        
        
    }
    
    
    
    
}
