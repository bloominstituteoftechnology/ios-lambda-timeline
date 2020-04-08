//
//  RecordingViewController.swift
//  LambdaTimeline
//
//  Created by Enrique Gongora on 4/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var recordingTextField: UITextField!
    @IBOutlet var cameraPreview: CameraPreviewView!
    
    // MARK: - Properties
    var postController: PostController!
    var videoPost: VideoPost?
    private var fileURL: URL?
    private lazy var captureSession = AVCaptureSession()
    private lazy var fileOutput = AVCaptureMovieFileOutput()
    var isRecording: Bool {
        fileOutput.isRecording
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraPreview.videoPlayerView.videoGravity = .resizeAspectFill
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermissionAndShowCamera()
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - Functions
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            requestVideoPermission()
        case .restricted:
            fatalError("Parental controls have been enabled. Video access is denied.")
        case .denied:
            fatalError("Tell User to enable permission for Video/Camera")
        case .authorized:
            setupCamera()
        @unknown default:
            fatalError("Apple added a new case for status that we aren't handling yet.")
        }
    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self, granted else {
                fatalError("Tell User to enable permission for Video/Camera")
            }
            DispatchQueue.main.async { self.setupCamera() }
        }
    }
    
    private func setupCamera() {
        // Creating the camera for use
        let camera = bestCamera()
        
        // Starting video configuration
        captureSession.beginConfiguration()
        
        // Inputs
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else { fatalError("Device configured incorrectly") }
        guard captureSession.canAddInput(cameraInput) else { fatalError("Unable to add camera input") }
        captureSession.addInput(cameraInput)
        
        // Resolution
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Microphone
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else { fatalError("Device configured incorrectly") }
        guard captureSession.canAddInput(audioInput) else { fatalError("Unable to add audio input") }
        captureSession.addInput(audioInput)
        
        // Outputs
        guard captureSession.canAddOutput(fileOutput) else { fatalError("Cannot add file output") }
        captureSession.addOutput(fileOutput)
        
        // We have reached the end and need to save the configuration to create a file
        captureSession.commitConfiguration()
        cameraPreview.session = captureSession
    }
    
    private func toggleRecordMode() {
        if isRecording {
            fileOutput.stopRecording()
        } else {
            guard let url = newRecordingURL() else { return }
            fileOutput.startRecording(to: url, recordingDelegate: self)
        }
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        fatalError("No cameras available")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError()
    }
    
    private func updateViews() {
        record.isSelected = isRecording
    }
    
    private func newRecordingURL() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mp4")
        return fileURL
    }
}

extension RecordingViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        fileURL = outputFileURL
        updateViews()
    }
}
