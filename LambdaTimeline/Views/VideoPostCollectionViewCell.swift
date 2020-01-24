//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by John Kouris on 1/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var playerView: UIView!
    
    var avQueuePlayer: AVQueuePlayer?
    var avPlayerLayer: AVPlayerLayer?
    
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
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        //        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
        //        labelBackgroundView.layer.borderWidth = 0.5
        labelBackgroundView.clipsToBounds = true
    }
    
    func addPlayer(for url: URL) {
        self.avQueuePlayer = AVQueuePlayer(url: url)
        self.avPlayerLayer = AVPlayerLayer(player: self.avQueuePlayer!)
        self.avPlayerLayer?.frame = self.playerView.bounds
        self.avPlayerLayer?.fillMode = .both
        self.playerView.layer.addSublayer(self.avPlayerLayer!)
        self.avQueuePlayer?.play()
    }
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
        
}
