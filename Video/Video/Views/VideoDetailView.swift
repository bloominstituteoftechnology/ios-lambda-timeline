//
//  VideoDetailView.swift
//  Video
//
//  Created by Wyatt Harrell on 5/7/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import AVFoundation

class VideoDetailView: UIView {
    
    var video: Video? {
        didSet {
            updateSubviews()
        }
    }
    
    let playerView = VideoPlayerView()
    private let descriptionLabel = UILabel()
    private let authorLabel = UILabel()
    private var player: AVPlayer! // We promise to set it before using it... or it'll crash
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        descriptionLabel.text = "Recorded By:"
        let placeDateStackView = UIStackView(arrangedSubviews: [descriptionLabel, authorLabel])
        placeDateStackView.spacing = UIStackView.spacingUseSystem
        placeDateStackView.axis = .horizontal
        placeDateStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeDateStackView)
        placeDateStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        placeDateStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        placeDateStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true

        addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.topAnchor.constraint(equalTo: placeDateStackView.bottomAnchor, constant: 8).isActive = true
        playerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        playerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        playerView.videoPlayerLayer.videoGravity = .resizeAspectFill
    }
    
    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        playerView.player = player
        player.play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Private Methods
    
    private func updateSubviews() {
        guard let video = video else { return }
        authorLabel.text = video.author
        playMovie(url: video.recordingURL)
    }
}

