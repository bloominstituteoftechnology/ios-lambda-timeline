//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Vici Shaweddy on 1/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: CameraPreviewView!
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer!
    var videoURL: URL?
    var postController = PostController()
    var playerView: PlaybackView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCamera()

        // Resize camera preview to fill the entire screen
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
    }
    
    private func updateViews() {
        // for changing the record button UI
        self.recordButton.isSelected = fileOutput.isRecording
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    private func setUpCamera() {
        let camera = bestCamera()
        captureSession.beginConfiguration()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Can't create an input form the camera, do something better than crashing")
        }
        
        // Add camera inputs
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("This session can't handle this type of input: \(cameraInput)")
        }
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Add audio inputs
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        
        guard captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        
        // Add video output (save movie)
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Can't record to disk")
        }
        
        captureSession.addOutput(fileOutput)
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }

    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        fatalError("No cameras on the device (ir running it on the iPhone simulator)")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    private func toggleRecord() {
        if self.fileOutput.isRecording {
            // stop recording
            self.fileOutput.stopRecording()
        } else {
            // start recording
            self.fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    // Creates a new file URL to Firebase
    
    private func newRecordingURL() -> URL {
        let documentsdirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsdirectory.appendingPathComponent(name).appendingPathExtension("mov")
        self.videoURL = fileURL
        return fileURL
    }
    
    func createVideoPost() {

        let alert = UIAlertController(title: "Add a title", message: nil, preferredStyle: .alert)
        
        var titleTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Video Title"
            titleTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Title", style: .default) { (_) in
            
            guard let titleText = titleTextField?.text,
                let videoURL = self.videoURL else { return }
            
            do {
                let videoData = try Data(contentsOf: videoURL)
                
                self.postController.createPost(with: titleText, ofType: .video, mediaData: videoData)
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {
                fatalError("Can't create a video post")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    func playMovie(url: URL) {
        if playerView == nil {
            playerView = PlaybackView()
            
            let topRect = self.view.bounds
            playerView.frame = topRect
            view.addSubview(playerView)
            
            playerView.playerLayer.videoGravity = .resizeAspectFill
            
            player?.pause()
            player = AVPlayer(url: url) // player item
            playerView.playerLayer.player = player // player layer
            
            player.play()
            loopVideo(videoPlayer: player)
        }
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recordPressed(_ sender: Any) {
        self.toggleRecord()
    }
    
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        print("Did finish recording: \(String(describing: videoURL))")
    
        guard let videoURL = self.videoURL else { return }
        self.playMovie(url: videoURL)
        
        self.createVideoPost()
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}

