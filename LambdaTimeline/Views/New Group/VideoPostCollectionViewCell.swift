//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import AVFoundation
import UIKit

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    var player: AVQueuePlayer!
    var videoURL: URL?
    var videoPost: VideoPost? {
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
        guard let videoPost = videoPost else { return }
        videoURL = videoPost.mediaURL
        titleLabel.text = videoPost.title 
        authorLabel.text = videoPost.author.displayName
    }
    
    private func playMovie(url: URL) {
        player = AVQueuePlayer(url: url)
       
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = VideoLayerView.frame
        
        VideoLayerView.layer.addSublayer(playerLayer)
        VideoLayerView.playerLayer = playerLayer
        VideoLayerView.layer.masksToBounds = true
        player.play()
        
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        labelBackgroundView.clipsToBounds = true
    }
    
    
    
    @IBAction func vidoePlayButtonTapped(_ sender: UIButton) {
        guard let videoURL = videoURL else { return }
        playMovie(url: videoURL)
    }
    
    
    
    
    @IBOutlet weak var vidoePlayButton: UIButton!
    @IBOutlet weak var VideoLayerView: VideoContainerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    
}
