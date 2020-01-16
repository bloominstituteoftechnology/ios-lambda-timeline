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

    private(set) var isPlaying: Bool = false

    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var videoPlayerViewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        get { return videoPlayerViewLayer.session }
        set { videoPlayerViewLayer.session = newValue }
    }

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
        let newPlayer = AVQueuePlayer(playerItem: item)
        let newLayer = AVPlayerLayer(player: newPlayer)
        // TODO: customize rectangle bounds?
        newLayer.frame = bounds

        looper = AVPlayerLooper(player: newPlayer, templateItem: item)
        playerLayer = newLayer
        player = newPlayer

        layer.addSublayer(newLayer)

        play()
    }
}
