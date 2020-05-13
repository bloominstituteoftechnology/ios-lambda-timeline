//
//  VideoCollectionViewCell.swift
//  VideoPost
//
//  Created by Jessie Ann Griffin on 5/12/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    var videoPost: VideoPost? {
        didSet {
            guard let videoPost = videoPost,
                let title = videoPost.videoTitle,
                let url = videoPost.videoURL else { return }
            videoTitleLabel.text = title
        }
    }
}
