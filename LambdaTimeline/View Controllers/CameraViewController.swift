//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_204 on 1/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//


import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer?

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    @IBOutlet var postBarButton: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Resize camera preview to fill the entire screen
        cameraView.videoPlayerView.videoGravity = .resize

        navigationItem.rightBarButtonItem = nil
        titleTextField.isHidden = true

        setupCamera()

        // TODO: Add tap gesture to replay the video (repeat loop)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tapGesture:)))
        view.addGestureRecognizer(tapGesture)

    }

    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .ended {
            playRecording()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }

    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecording()
    }

    // Methods

    func playRecording() {
        if let player = player {
            player.seek(to: .zero)
            player.play()
        }
    }

    func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }

    func toggleRecording() {
        if fileOutput.isRecording {
            // stop
            fileOutput.stopRecording()
        } else {
            // start
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }

    func setupCamera() {
        let camera = bestCamera()

        captureSession.beginConfiguration()

        // make changes to the devices connected

        // Video input
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Cannot create camera input")
        }
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("Cannot add camera input to session")
        }
        captureSession.addInput(cameraInput)

        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.canSetSessionPreset(.hd1920x1080)
        }

        // Audio input
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        guard captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        captureSession.addInput(audioInput)


        // Video output
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Can't setup the file output for the movie")
        }
        captureSession.addOutput(fileOutput)

        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }

    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }

    /// WideAngle lends is on every iPhone thats been shipped through 2019
    private func bestCamera() -> AVCaptureDevice {
        // Fallback camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }

        fatalError("No cameras on the device. Or you are running on the Simulator (not supported)")
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

    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        //player?.actionAtItemEnd = .none
        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.frame = cameraView.frame
        playerLayer.videoGravity = .resize
        view.layer.addSublayer(playerLayer)
        player?.play()
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        print("Video: \(outputFileURL.path)")
        updateViews()
        navigationItem.rightBarButtonItem = postBarButton
        titleTextField.isHidden = false
        playMovie(url: outputFileURL)
    }

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}
