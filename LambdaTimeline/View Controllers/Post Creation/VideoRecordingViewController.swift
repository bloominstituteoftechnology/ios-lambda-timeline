//
//  VideoRecordingViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoRecordingViewController: UIViewController {
	/// hide this when video is recording - makes it really hard to accidentally NOT record
	@IBOutlet private var indicatorContainer: UIView!
	@IBOutlet private var recordButton: UIButton!
	@IBOutlet private var playbackButton: UIButton!
	@IBOutlet private var cameraPreviewView: CameraPreviewView!

	var videoHelper: VideoSessionManager?

	override func viewDidLoad() {
		super.viewDidLoad()

		recordButton.tintColor = .systemRed
		playbackButton.tintColor = .systemGreen

		checkCameraPermission()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		videoHelper?.startRunning()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		videoHelper?.stopRunning()
	}

	private func setupCamera() {
		do {
			videoHelper = try VideoSessionManager()
			cameraPreviewView.session = videoHelper?.captureSession
			videoHelper?.startRunning()
		} catch {
			NSLog("Error creating camera helper: \(error)")
		}
	}

	private func checkCameraPermission() {
		let status = AVCaptureDevice.authorizationStatus(for: .video)

		switch status {
		case .notDetermined:
			requestCameraPermission()
		case .authorized:
			setupCamera()
		default:
			// show error saying to check permissions
			showPermissionError()
		}
	}

	private func requestCameraPermission() {
		AVCaptureDevice.requestAccess(for: .video) { granted in
			if granted == false {
				DispatchQueue.main.async {
					self.showPermissionError()
				}
			} else {
				DispatchQueue.main.async {
					self.setupCamera()
				}
			}
		}
	}

	private func showPermissionError() {
		let alertVC = UIAlertController(title: "Permissions Error",
										message: "Access to the camera has not been granted. Please check the Settings app to allow camera access.",
										preferredStyle: .alert)
		let okay = UIAlertAction(title: "Okie Dokey", style: .default)
		alertVC.addAction(okay)
		present(alertVC, animated: true)
	}

	@IBAction func recordButtonDown(_ sender: UIButton) {
		indicatorContainer.isHidden = true
	}

	@IBAction func recordButtonUp(_ sender: UIButton) {
		indicatorContainer.isHidden = false
	}

	@IBAction func playButtonPressed(_ sender: UIButton) {
	}

}
