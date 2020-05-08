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

    // MARK: - IBOutlets
    @IBOutlet weak var videoPlayer: VideoPlayerView!
    
    // MARK: - Properties
    private var player: AVPlayer!
    var recordingURL: URL?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        playMovie(url: recordingURL)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
    }
    
    // MARK: - Private Methods
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
}
