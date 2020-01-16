//
//  AudioPostDetailViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

class AudioPostDetailViewController: PostDetailViewController {

    override var avManageable: AVManageable? { audioPlayerControl }
    
    @IBOutlet weak var audioPlayerControl: AudioPlayerControl!

    override func updateViews() {
        super.updateViews()
        guard let data = mediaData else { return }
        audioPlayerControl.loadAudio(from: data)
    }
}
