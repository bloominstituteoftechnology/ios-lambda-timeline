//
//  PlayerController.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/4/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import AVFoundation

class PlayerController {
    var player: AVPlayer?
    var videoURL: URL? {
        didSet {
            guard let videoURL = videoURL else { return }
            setMovie(url: videoURL)
        }
    }
    
    func togglePlayback() {
        guard let player = player else { return }
        
        switch player.timeControlStatus {
        case .playing:
            player.play()
        case .paused:
            player.pause()
        default:
            player.play()
        }
    }
    
    private func setMovie(url: URL) {
        let player = AVPlayer(url: url)
        self.player = player
    }
}
