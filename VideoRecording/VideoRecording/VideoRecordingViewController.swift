//
//  VideoRecordingViewController.swift
//  VideoRecording
//
//  Created by Chris Gonzales on 4/8/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import AVFoundation

class VideoRecordingViewController: UIViewController {

    // MARK: - Properties
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    private var player: AVPlayer!
    
    // MARK: - Outlets
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var lightButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func cameraTapped(_ sender: UIButton) {
        if fileOutput.isRecording {
                      fileOutput.stopRecording()  // Future: Play with pausing using another button
                  } else {
                      fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
                  }
    }
    @IBAction func flipTapped(_ sender: UIButton) {
    }
    @IBAction func lightTapped(_ sender: UIButton) {
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        
        setUpCaptureSession()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    func updateViews() {
        cameraButton.isSelected = fileOutput.isRecording
    }
    
    // MARK: - Selector Methods
    
    @objc private func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        print("tap")
        
        switch tapGesture.state {
            case .ended:
                replayVideoRecording()
            default:
                break // ignore all other states
        }
    }
    
    // MARK: - Private Methods
    
    private func replayVideoRecording() {
        guard let player = player else { return }
        
        // 30 FPS, 60 FPS, 24 Frames Per Second
        // CMTime (0, 30) = 1st frame
        // CMTime(1, 30) = 2nd frame ...
        player.seek(to: .zero)
        player.play()
    }

    private func setUpCaptureSession() {
        
        captureSession.beginConfiguration()
        
        // Add inputs
        let camera = bestCamera()
        
        // Video
        guard let captureInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(captureInput) else {
                fatalError("Can't create the input form the camera")
        }
        captureSession.addInput(captureInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) { // FUTURE: Play with 4k
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Audio
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Can't create microphone input")
        }
        captureSession.addInput(audioInput)
        
        // Add outputs
        
        // Recording to disk
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record to disk")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        
        // Live preview
        cameraView.session = captureSession
    }

    private func bestCamera() -> AVCaptureDevice {
        // All iPhones have a wide angle camera (front + back)
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        
        if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideCamera
        }
        
        // Future: Add a button to toggle front/back camera
        
        fatalError("No cameras on the device (or you're running this on a Simulator which isn't supported)")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }

    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    // MARK: - General Methods
    
    func playVideoRecording(url: URL) {
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        var topRect = cameraView.bounds
        topRect.size.height = topRect.size.height
        topRect.size.width = topRect.size.width
        topRect.origin.y = view.layoutMargins.top
        playerLayer.frame = topRect
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
}
