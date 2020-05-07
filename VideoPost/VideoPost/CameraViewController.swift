//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    // MARK: - Properites

    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()

    private var player: AVPlayer! // Implicetly unwrapped optional. we promise to set it before using it ... or it'll crash!

    // MARK: - Actions

    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecord()
    }

    @IBAction func saveButton(_ sender: UIButton) {
    }

    // MARK: - Outlets

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    @IBOutlet weak var clipNameTextField: UITextField!
    @IBOutlet weak var saveButtonOutlet: UIButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
		super.viewDidLoad()

		// Resize camera preview to fill the entire screen
        // TODO: ? How does this work?
//		cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        setUpCaptureSession()

        // Setup the Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)

        // Increase the size of the start/stop button
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .regular, scale: .large)
        let largeStart = UIImage(systemName: "camera.fill", withConfiguration: largeConfig)
        recordButton.setImage(largeStart, for: .normal)

        let largeStop = UIImage(systemName: "stop.circle.fill", withConfiguration: largeConfig)
        recordButton.setImage(largeStop, for: .selected)

        // Save button initially disabled
        saveButtonOutlet.isEnabled = false
    }

    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        print("tap")

        view.endEditing(true)

        switch(tapGesture.state) {

        case .ended:
            replayMovie()
        default:
            print("Handled other states: \(tapGesture.state)")
        }
    }

    private func replayMovie() {
        guard let player = player else { return }

        // 30 FPS, 60 FPS, 24 Frames Per Second
        // CMTime (0, 30) = 1st frame
        // CMTime(1, 30) = 2nd frame ...
        player.seek(to: .zero)
        player.play()
    }

    // Use viewWillAppear so that before the view is displayed, we give the system time to load in video frames
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }

    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }

    // MARK: - Private

    // Live Preview + inputs/outputs

    private func setUpCaptureSession() {
        // Add inputs
        captureSession.beginConfiguration()
        // Camera input
        let camera = bestCamera()

        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Error adding camera to capture session")
        }
        captureSession.addInput(cameraInput)

        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }

        // Audio Microphone input
        let microphone = AVCaptureDevice.default(for: .audio)! // No audio if crashes

        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Can't create microphone input")
        }
        captureSession.addInput(audioInput)

        // Add outputs
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Error: cannot save movie with capture session")
        }
        captureSession.addOutput(fileOutput)

        captureSession.commitConfiguration()
        cameraView.session = captureSession
        // TODO: Start/Stop session
    }

    private func bestCamera() -> AVCaptureDevice {
        // FUTURE: Toggle between front/back with a button

        // Ultra-wide lense (iPhone 11 Pro + Pro Max on back)
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        // Wide angle lense (available on any iPhone - front/back)
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }

        // No cameras present (simulator)
        fatalError("No camera avaialble - are you on a simulator?")
    }

    // Recording

    // DRY: Don't repeat yourself
    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()

            // Enable Save button
            saveButtonOutlet.isEnabled = true
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }

	/// Creates a new file URL in the documents directory
	private func newRecordingURL() -> URL {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]

		let name = formatter.string(from: Date())
		let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
		return fileURL
	}

    private func playMovie(url: URL) {
        player = AVPlayer(url: url)

        let playerView = VideoPlayerView()
        playerView.player = player

        // top left corner (Fullscreen, you'd need a close button)
        var topRect = view.bounds
        topRect.size.height = topRect.size.height / 4
        topRect.size.width = topRect.size.width / 4 // create a constant for the "magic number"
        topRect.origin.y = view.layoutMargins.top
        playerView.frame = topRect
        view.addSubview(playerView) // FIXME: Don't add every time we play
        
        player.play()
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        } else {
            // show movie
            playMovie(url: outputFileURL)
        }
        
        updateViews()
    }

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("startedRecording: \(fileURL)")
        updateViews()
    }
}
