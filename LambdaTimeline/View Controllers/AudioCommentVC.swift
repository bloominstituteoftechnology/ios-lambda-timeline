//
//  AudioCommentVC.swift
//  LambdaTimeline
//
//  Created by Jeffrey Santana on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentVC: UIViewController {

	// MARK: - IBOutlets

	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var elapsedTimeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var previewButton: UIButton!
	@IBOutlet weak var recordButton: UIButton!
	
	// MARK: - Properties

	private var player = AudioPlayer()
	private var recorder = AudioRecorder()
	private lazy var timeFormatter: DateComponentsFormatter = {
		let formatting = DateComponentsFormatter()
		formatting.unitsStyle = .positional
		formatting.zeroFormattingBehavior = .pad
		formatting.allowedUnits = [.minute, .second]
		return formatting
	}()
	var audioProgressPercentage: Float {
		Float(player.elapsedTime / player.duration) * 100
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		elapsedTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: elapsedTimeLabel.font.pointSize,
														  weight: .regular)
		durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: durationLabel.font.pointSize,
																   weight: .regular)
		
		player.delegate = self
		recorder.delegate = self
		
		#warning("Clean up file manager")
		let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		print("Doc dir: \(documentDir.path)")
		
		updateViews()
	}
	
	// MARK: - IBActions
	
	@IBAction func previewButtonPressed(_ sender: Any) {
		player.play()
		updateProgressBar()
	}
	
	@IBAction func recordButtonPressed(_ sender: Any) {
		recorder.toggleRecording()
	}
	
	// MARK: - Helpers
	
	private func updateViews() {
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
			#warning("Bang-bang")
			try! player.load(url: url)
		}
	}
}
