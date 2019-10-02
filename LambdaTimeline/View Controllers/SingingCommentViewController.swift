//
//  SingingCommentViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SingingCommentViewController: UIViewController {

	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private var recordButton: UIButton!
	@IBOutlet private var previewButton: UIButton!

	var recorder: AudioRecorder?
	var playbackPreview: AudioPlayer?
	var lastRecording: URL?

	override func viewDidLoad() {
		super.viewDidLoad()
		createNewRecorder()
	}

	private func createNewRecorder() {
		let file = AudioRecorder.newTmpFilehandle
		do {
			recorder = try AudioRecorder(recordingTo: file)
			recorder?.delegate = self
		} catch {
			NSLog("Error creating a new recording: \(error)")
		}
	}

	private func cleanupLastRecording() {
		guard let lastRecording = lastRecording else { return }
		playbackPreview = nil
		do {
			try FileManager.default.removeItem(at: lastRecording)
		} catch {
			NSLog("Error deleting temp file: \(error)")
		}
		self.lastRecording = nil
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		recorder = nil
	}

	private func updateViews() {
		let recordButtonTitle: String
		if recorder?.isRecording == true {
			activityIndicator.isHidden = false
			activityIndicator.startAnimating()
			recordButtonTitle = "Stop Recording"
		} else {
			activityIndicator.isHidden = true
			recordButtonTitle = "Record"
		}
		recordButton.setTitle(recordButtonTitle, for: .normal)

		if lastRecording != nil {
			if playbackPreview?.isPlaying == true {
				previewButton.isEnabled = false
			} else {
				previewButton.isEnabled = true
			}
		} else {
			previewButton.isEnabled = false
		}
	}


	@IBAction func recordButtonPressed(_ sender: UIButton) {
		playbackPreview?.stop()
		if lastRecording != nil {
			cleanupLastRecording()
		}
		recorder?.toggleRecording()
	}

	@IBAction func previewButtonPressed(_ sender: UIButton) {
		if let lastRecording = lastRecording, lastRecording != playbackPreview?.currentFile {
			do {
				playbackPreview = try AudioPlayer(with: lastRecording)
				playbackPreview?.delegate = self
			} catch {
				NSLog("Error opening recording: \(error)")
			}
		}
		playbackPreview?.playPause()
	}
}

extension SingingCommentViewController: AudioRecorderDelegate {
	func recorderDidChangeState(_ recorder: AudioRecorder) {
		updateViews()
	}

	func recorderDidFinishSavingFile(_ recorder: AudioRecorder, url: URL) {
		if !recorder.isRecording {
			cleanupLastRecording()
			lastRecording = url
			createNewRecorder()
			updateViews()
		}
	}
}

extension SingingCommentViewController: AudioPlayerDelegate {
	func playerDidChangeState(_ player: AudioPlayer) {
		updateViews()
	}

	func playerPlaybackLoopUpdated(_ player: AudioPlayer) {
		//
	}


}
