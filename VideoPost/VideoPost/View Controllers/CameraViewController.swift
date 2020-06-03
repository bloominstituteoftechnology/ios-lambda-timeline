//
//  CameraViewController.swift
//  VideoPost
//
//  Created by Chris Dobek on 6/3/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    // MARK: Properties
    weak var delegate: VideoCollectionViewController!
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    private var videoFileURL: URL?
    private var player: AVPlayer!
    
    // MARK: Outlets
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    // MARK: - Actions
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecord()
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let fileURL = videoFileURL else { return }
        
        delegate?.videos.append(fileURL)
        let thumbnail = delegate?.createThumbnail(url: fileURL)
        delegate?.thumbnails.append(thumbnail)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        // Save button disabled
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
        player.seek(to: .zero)
        player.play()
    }
    
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
    
    private func setUpCaptureSession() {
        // Add inputs
        captureSession.beginConfiguration()
        // Camera
        let camera = bestCamera()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Error adding camera to capture session")
        }
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Microphone
        let microphone = AVCaptureDevice.default(for: .audio)! // No audio if crashes
        
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Can't create microphone input")
        }
        captureSession.addInput(audioInput)
        
        // Outputs
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Error: cannot save movie with capture session")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        
        // Ultra-wide lense (iPhone 11 Pro + Pro Max on back)
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        // Wide angle lense (available on any iPhone - front/back)
        // FUTURE: Toggle between front/back with a button
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        
        // No cameras present (simulator)
        fatalError("No camera avaialble - are you on a simulator?")
    }
    
    // MARK: Recording
    
    /// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            
            // Enable Save button
            saveButtonOutlet.isEnabled = true
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        let playerView = VideoPlayerView()
        playerView.player = player
        
        
        var topRect = view.bounds
        topRect.size.height = topRect.size.height / 4
        topRect.size.width = topRect.size.width / 4
        
        topRect.origin.y = cameraView.frame.origin.y
        playerView.frame = topRect
        view.addSubview(playerView)
        
        player.play()
    }
    
    
    
    
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        } else {
            // show movie
            videoFileURL = outputFileURL
            playMovie(url: outputFileURL)
        }
        
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("startedRecording: \(fileURL)")
        updateViews()
    }
}
