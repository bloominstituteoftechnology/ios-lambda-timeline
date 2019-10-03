//
//  VideoPlayerView.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPlayerViewDelegate: AnyObject {
	func videoPlayerViewStatusChanged(_ videoPlayerView: VideoPlayerView)
}

class VideoPlayerView: UIView {
	private var player: AVPlayer?
	private var playerLayer: AVPlayerLayer?

	weak var delegate: VideoPlayerViewDelegate?

	private var stopNotification: NSObjectProtocol?

	override func awakeFromNib() {
		super.awakeFromNib()
		stopNotification = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { _ in
			self.stop()
			self.notifyDelegate()
		})
	}

	deinit {
		stopNotification = nil
	}

	var isPlaying: Bool {
		guard let player = player else { return false }
		return player.rate != 0 && player.error == nil
	}

	func loadMovie(url: URL) {
		playerLayer?.removeFromSuperlayer()
		playerLayer = nil

		player = AVPlayer(url: url)
		let newPlayerLayer = AVPlayerLayer(player: player)
		newPlayerLayer.videoGravity = .resizeAspectFill
		playerLayer = newPlayerLayer
		playerLayer?.frame = bounds

		layer.addSublayer(newPlayerLayer)
		notifyDelegate()
	}

	func play() {
		player?.play()
		notifyDelegate()
	}

	func stop() {
		player?.pause()
		player?.seek(to: CMTime.zero)
		notifyDelegate()
	}

	func pause() {
		player?.pause()
		notifyDelegate()
	}

	func playPauseToggle() {
		if isPlaying {
			pause()
		} else {
			play()
		}
	}

	func playStopToggle() {
		if isPlaying {
			stop()
		} else {
			play()
		}
	}

	private func notifyDelegate() {
		delegate?.videoPlayerViewStatusChanged(self)
	}
}
