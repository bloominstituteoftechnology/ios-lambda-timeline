//
//  RecordingViewController.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var TitleTextField: UITextField!
    var videoPost: VideoPost?
    var postController: PostController!
    private lazy var fileOutput = AVCaptureMovieFileOutput()
    private lazy var captureSession = AVCaptureSession()
    private var fileURL: URL?
    var isRecording: Bool {
        fileOutput.isRecording
    }
    @IBOutlet var cameraView: CameraPreviewView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            setUpCamera()
        @unknown default:
            fatalError("Apple added a new case for status that we aren't handling yet.")
        }

    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self, granted else {
                fatalError("Tell User to enable permission for Video/Camera")
            }
            DispatchQueue.main.async { self.setUpCamera() }
        }
    }
    
    
    private func setUpCamera() {
        let camera = bestCamera()
        captureSession.beginConfiguration()
        
        //Inputs
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else { fatalError("Device configured incorrectly") }
        guard captureSession.canAddInput(cameraInput) else { fatalError("Unable to add camera input") }
        captureSession.addInput(cameraInput)
        
        //Resolution
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        //Microphone
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else { fatalError("Device configured incorreclty") }
        guard captureSession.canAddInput(audioInput) else { fatalError("Unable to add audio") }
        captureSession.addInput(audioInput)
        
        //Output
        guard captureSession.canAddOutput(fileOutput) else { fatalError("Cannot add file output") }
        captureSession.addOutput(fileOutput)
        
        // we have reached the end and need to save the configureation to create a file
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
        guard let title = TitleTextField.text, !title.isEmpty,
        let url = fileURL,
        let videoData = try? Data(contentsOf: url)  else { return }
        postController.createPost(with: title, ofType: .video, mediaData: videoData) { success in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post")
                }
                return
            }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
            return device
        }
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        }
        fatalError("No camera")
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
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
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
