//
//  VideoSessionManager.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation

enum VideoSessionError: Error {
	case cannotAddInput
	case cannotCreateInput
	case requestedCameraNotAvailable
	case requestedAudioNotAvailable
}

class VideoSessionManager {
	private(set) lazy var captureSession = AVCaptureSession()

	var cameraPosition: AVCaptureDevice.Position
	var capturePreset: AVCaptureSession.Preset

	var isRunning: Bool {
		return captureSession.isRunning
	}

	init(cameraPosition: AVCaptureDevice.Position = .back, capturePreset: AVCaptureSession.Preset = .hd1280x720) throws {
		self.cameraPosition = cameraPosition
		self.capturePreset = capturePreset
		try setupCamera()
	}

	private func setupCamera() throws {
		captureSession.beginConfiguration()
		let camera = try getWideCamera()
		try addCameraInput(camera: camera)
		setPreset()
		let mic = try getAudioDevice()
		try addAudioDevice(device: mic)
		captureSession.commitConfiguration()
	}

	// MARK: - Session Control
	func startRunning() {
		if !isRunning {
			captureSession.startRunning()
		}
	}

	func stopRunning() {
		if isRunning {
			captureSession.stopRunning()
		}
	}

	// MARK: - Camera Setup helpers
	private func addCameraInput(camera: AVCaptureDevice) throws {
		let cameraInput = try AVCaptureDeviceInput(device: camera)
		guard captureSession.canAddInput(cameraInput) else { throw VideoSessionError.cannotAddInput }
		captureSession.addInput(cameraInput)
	}

	@discardableResult private func setPreset() -> Bool {
		guard captureSession.canSetSessionPreset(capturePreset) else { return false }
		captureSession.sessionPreset = capturePreset
		return captureSession.sessionPreset == capturePreset
	}

	private func getWideCamera() throws -> AVCaptureDevice {
		if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) {
			return device
		}

		if let device = AVCaptureDevice.default(for: .video) {
			NSLog("Back camera not an option. Falling back to default video device...")
			return device
		}

		throw VideoSessionError.requestedCameraNotAvailable
	}

	// MARK: - Audio Setup Helpers
	private func getAudioDevice() throws -> AVCaptureDevice {
		if let device = AVCaptureDevice.default(for: .audio) {
			return device
		}

		throw VideoSessionError.requestedAudioNotAvailable
	}

	private func addAudioDevice(device: AVCaptureDevice) throws {
		let audioInput = try AVCaptureDeviceInput(device: device)

		guard captureSession.canAddInput(audioInput) else { throw VideoSessionError.cannotAddInput }
		captureSession.addInput(audioInput)
	}
}
