//
//  VideoPostDetailViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

class VideoPostDetailViewController: PostDetailViewController {

    override var avManageable: AVManageable? { videoPreviewView }

    @IBOutlet var videoPreviewView: VideoPreviewView!

    override func updateViews() {
        super.updateViews()
        guard let data = mediaData else { return }
        try? videoPreviewView.loadVideo(data: data)
    }
}
