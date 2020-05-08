//
//  RecordingCollectionViewCell.swift
//  VideoPosts
//
//  Created by Tobi Kuyoro on 07/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var playerView: VideoPlayerView!

    // MARK: - Properties

    var recording: Recording?
    var player: AVPlayer!

    // MARK: - IBActions

    @IBAction func pressPlayTapped(_ sender: Any) {
        guard let recording = recording else { return }
        playMovie(url: recording.url)
    }

    // MARK: - Actions

    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        playerView.player = player
        playerView.backgroundColor = .white
        player.play()
    }
}
