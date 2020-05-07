//
//  EditVideoViewController.swift
//  iosVideo
//
//  Created by Karen Rodriguez on 5/6/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import AVFoundation

class EditVideoViewController: UIViewController {

    var videoURL: URL? {
        didSet {
            playVideo()
        }
    }

    @IBOutlet weak var playerView: VideoPlayerView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playVideo()
    }

    private func playVideo() {
        if isViewLoaded {
            guard let url = videoURL else { return }
            var player = AVPlayer(url: url)
            playerView.player = player
            player.play()
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
