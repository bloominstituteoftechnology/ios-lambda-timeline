//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class VideoPostCollectionViewCell: PostCollectionViewCell {

    @IBOutlet var videoPreviewView: VideoPreviewView!

    override func prepareForReuse() {
        super.prepareForReuse()
        videoPreviewView.unloadVideo()
    }
}
