//
//  WatchVideoViewController.swift
//  Video
//
//  Created by Wyatt Harrell on 5/6/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import AVFoundation

class WatchVideoViewController: UIViewController {

    @IBOutlet weak var videoPlayer: VideoPlayerView!
    
    private var player: AVPlayer!
    
    var recordingURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        playMovie(url: recordingURL)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
    }
    
    private func updateViews() {
        videoPlayer.videoPlayerLayer.videoGravity = .resizeAspectFill
    }
    
    private func playMovie(url: URL?) {
        guard let url = url else { return }
        print("playing \(url)")
        player = AVPlayer(url: url)
        videoPlayer.player = player
        player.play()
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
