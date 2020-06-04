//
//  PlayerViewController.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/4/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    var videoURL: URL?
    
    let playerController = PlayerController()

    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        playerController.videoURL = videoURL
    }
    
    @IBAction func togglePlayback(_ sender: Any) {
        togglePlayback()
    }
    
    private func togglePlayback() {
        playerController.togglePlayback()
        updateViews()
    }
    
    private func updateViews() {
        guard let player = playerController.player else { return }
        
        switch player.timeControlStatus {
        case .playing:
            playButton.isSelected = true
        default:
            playButton.isSelected = false
        }
    }
    
    private func playMovie() {
        playerView.player = playerController.player
    }
}
