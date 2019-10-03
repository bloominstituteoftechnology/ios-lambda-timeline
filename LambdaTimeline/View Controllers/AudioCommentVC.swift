//
//  AudioCommentVC.swift
//  LambdaTimeline
//
//  Created by Jeffrey Santana on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol AudioCommentDelegate {
	func didSaveAudioComment(newComment: Comment?)
}

class AudioCommentVC: UIViewController {

	// MARK: - IBOutlets

	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var elapsedTimeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var previewButton: UIButton!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var postButton: UIButton!
	
	// MARK: - Properties
	
    var postController: PostController!
	var post: Post!
	var delegate: AudioCommentDelegate?
	private var player: AudioPlayer?
	private var recorder = AudioRecorder()
	private lazy var timeFormatter: DateComponentsFormatter = {
		let formatting = DateComponentsFormatter()
		formatting.unitsStyle = .positional
		formatting.zeroFormattingBehavior = .pad
		formatting.allowedUnits = [.minute, .second]
		return formatting
	}()
	private var audioProgressPercentage: Float {
		guard let player = player else { return 0 }
		return Float(player.elapsedTime / player.duration) * 100
	}
	private var audioURL: URL?
	
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		elapsedTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: elapsedTimeLabel.font.pointSize,
														  weight: .regular)
		durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: durationLabel.font.pointSize,
																   weight: .regular)
		
		recorder.delegate = self
		
		#warning("Clean up file manager")
		let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		print("Doc dir: \(documentDir.path)")
		
		postButton.isEnabled = false
		updateViews()
	}
	
	// MARK: - IBActions
	
	@IBAction func previewButtonPressed(_ sender: Any) {
		player?.play()
		updateProgressBar()
	}
	
	@IBAction func recordButtonPressed(_ sender: Any) {
		recorder.toggleRecording()
	}
	
	@IBAction func postBtnTapped(_ sender: Any) {
		guard let url = audioURL,
			let audioData = try? Data(contentsOf: url) else { return }
		
		postController.addAudioComment(with: audioData, to: post) { comment in
			self.delegate?.didSaveAudioComment(newComment: comment)
		}
		
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func cancelBtnTapped(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Helpers
	
	private func updateViews() {
		guard let player = player else { return }
		previewButton.isEnabled = !player.isPlaying
		recordButton.tintColor = recorder.isRecording ? .gray : .red
		elapsedTimeLabel.text = timeFormatter.string(from: player.elapsedTime)
		durationLabel.text = timeFormatter.string(from: player.duration)
		
		updateProgressBar()
	}
	
	private func updateProgressBar() {
		print(audioProgressPercentage)
		progressView.setProgress(audioProgressPercentage, animated: true)
	}
}

extension AudioCommentVC: AudioPlayerDelegate {
	func playerDidChangeState(_ player: AudioPlayer) {
		updateViews()
	}
}

extension AudioCommentVC: AudioRecorderDelegate {
	func recorderDidChangeState(_ recorder: AudioRecorder) {
		updateViews()
	}
	
	func recorderDidFinishSavingFile(_ recorder: AudioRecorder, url: URL) {
		if !recorder.isRecording {
			do {
				player = try AudioPlayer(with: url)
				player?.delegate = self
				audioURL = url
				postButton.isEnabled = true
			} catch {
				NSLog("Could not play recording")
			}
		}
	}
}
