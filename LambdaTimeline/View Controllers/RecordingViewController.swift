//
//  RecordingViewController.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import AVFoundation
import UIKit

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet var cameraView: CameraPreviewView!
    
    var postController: PostController!
    var videoPost: VideoPost?
    private var fileURL: URL?
    private lazy var captureSession = AVCaptureSession()
    private lazy var fileOutput = AVCaptureMovieFileOutput()
    var isRecording: Bool {
        fileOutput.isRecording
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
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
        cameraView.session = captureSession
    }
    
    private func toggleRecordMode() {
        if isRecording {
            fileOutput.stopRecording()
        } else {
            guard let url = newRecordingURL() else { return }
            fileOutput.startRecording(to: url, recordingDelegate: self)
        }
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        toggleRecordMode()
    }
    
    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard let title = titleTextField.text,
            !title.isEmpty,
            let url = fileURL,
            let videoData = try? Data(contentsOf: url) else { return }
        
        let postOperation = BlockOperation {
            self.postController.createPost(with: title, ofType: .video, mediaData: videoData) { success in
                guard success else {
                    DispatchQueue.main.async {
                        self.presentInformationalAlertController(title: "Error", message: "Unable to create post")
                    }
                    return
                }
            }
        }
        
        let completionOperation = BlockOperation {
            self.navigationController?.popViewController(animated: true)
        }
        
        completionOperation.addDependency(postOperation)
        OperationQueue.main.addOperation(completionOperation)
        OperationQueue.main.addOperation(postOperation)
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
        recordButton.isSelected = isRecording
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
