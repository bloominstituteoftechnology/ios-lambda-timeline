//
//  VideoPreviewView.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPreviewView: UIView {

    var isPlaying: Bool = false {
        willSet (willPlay) {
            guard willPlay != isPlaying else { return }
            willPlay ? play() : pause()
        }
    }

    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        // add tap gesture to replay video (repeat loop?)
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(viewTapped(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc
    func viewTapped(_ tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .ended {
            togglePlaying()
        }
    }

    func togglePlaying() {
        isPlaying ? pause() : play()
    }

    func play() {
        guard let player = player else { return }
        player.play()
        isPlaying = true
    }

    func pause() {
        guard let player = player else { return }
        player.pause()
        isPlaying = false
    }

    func setUpVideoAndPlay(url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)

        looper = AVPlayerLooper(player: player, templateItem: item)
        playerLayer = AVPlayerLayer(player: player)
        self.player = player

        // TODO: customize rectangle bounds
        playerLayer?.frame = frame

        play()
    }
}
