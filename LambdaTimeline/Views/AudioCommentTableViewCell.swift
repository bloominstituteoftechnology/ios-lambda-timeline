//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentTableViewCell: UITableViewCell {

	@IBOutlet private var authorLabel: UILabel!
	@IBOutlet private var playPauseButton: UIButton!
	@IBOutlet private var progressSlider: UISlider!
	@IBOutlet private var timeProgressLabel: UILabel!

	let playImage = UIImage(systemName: "play.fill")
	let pauseImage = UIImage(systemName: "pause.fill")

	var comment: Comment? {
		didSet {
			updateViews()
			downloadAudio()
		}
	}
	var audioData: Data? {
		didSet {
			guard let audioData = audioData else { return }
			audioPlayer = try? AudioPlayer(with: audioData)
			audioPlayer?.delegate = self
			updateViews()
		}
	}
	var audioPlayer: AudioPlayer?

	var audioDownloadTask: URLSessionDataTask?

	private lazy var timeFormatter: DateComponentsFormatter = {
		let formatting = DateComponentsFormatter()
		formatting.unitsStyle = .positional // 00:00
		formatting.zeroFormattingBehavior = .pad
		formatting.allowedUnits = [.minute, .second]
		return formatting
	}()

	override func awakeFromNib() {
		super.awakeFromNib()
		timeProgressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
	}

	private func updateViews() {
		guard let comment = comment else { return }
		authorLabel.text = comment.author.displayName
		updateAudioStuff()
	}

	private func updateAudioStuff() {
		progressSlider.isEnabled = false
		if let audioPlayer = audioPlayer {
			progressSlider.value = audioPlayer.elapsedTime.floatValue
			progressSlider.maximumValue = audioPlayer.duration.floatValue
			timeProgressLabel.text = timeFormatter.string(from: audioPlayer.elapsedTime)
			playPauseButton.isEnabled = true
		} else {
			progressSlider.minimumValue = 0
			progressSlider.value = 0
			progressSlider.maximumValue = 1
			timeProgressLabel.text = timeFormatter.string(from: 0)
			playPauseButton.isEnabled = false
		}
	}

	private func audioUpdateLoop() {
		guard let audioPlayer = audioPlayer else { return }
		progressSlider.value = audioPlayer.elapsedTime.floatValue
		progressSlider.maximumValue = audioPlayer.duration.floatValue
		timeProgressLabel.text = timeFormatter.string(from: audioPlayer.elapsedTime)

		if audioPlayer.isPlaying {
			playPauseButton.setImage(pauseImage, for: .normal)
		} else {
			playPauseButton.setImage(playImage, for: .normal)
		}
	}

	private func downloadAudio() {
		guard let audioURL = comment?.audioURL else { return }
		audioDownloadTask?.cancel()
		audioDownloadTask = URLSession.shared.dataTask(with: audioURL, completionHandler: { audioData, _, error in
			if let error = error {
				NSLog("Error downloading file: \(error)")
				return
			}

			DispatchQueue.main.async {
				self.audioData = audioData
			}
		})
		audioDownloadTask?.resume()
	}

	@IBAction func playPauseButtonPressed(_ sender: UIButton) {
		audioPlayer?.playPause()
	}

}

extension AudioCommentTableViewCell: AudioPlayerDelegate {
	func playerDidChangeState(_ player: AudioPlayer) {
		audioUpdateLoop()
	}

	func playerPlaybackLoopUpdated(_ player: AudioPlayer) {
		audioUpdateLoop()
	}
}
