//
//  CameraViewController.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/14/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    //MARK: - Properties
    lazy var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer?
    var playerView: VideoPlayerView!
    
    //MARK: - IBOutlets
    @IBOutlet var cameraPreview: CameraPreviewView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var videoTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCaptureSession()
        cameraPreview.videoPlayerView.videoGravity = .resizeAspectFill
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    // MARK: - IBAction
    @IBAction func recordButtonPressed(_ sender: Any) {
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    // MARK: - Functions
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    func updateViews() {
        self.recordButton.isSelected = fileOutput.isRecording
    }
    
    func setUpCaptureSession() {
        captureSession.beginConfiguration()

        let camera = bestCamera()

        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            showAlertMessage(title: "Camera Error", message: "Error in getting camera access", actiontitle: "Ok")
            return
        }
        captureSession.addInput(cameraInput)

        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Can't create and add input from microphone")
        }
        captureSession.addInput(audioInput)

        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }

        guard captureSession.canAddOutput(fileOutput) else {
            showAlertMessage(title: "Cannot add output", message: "Output not added", actiontitle: "Ok")
            return
        }
        captureSession.addOutput(fileOutput)

        captureSession.commitConfiguration()

        cameraPreview.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }

        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) { // try .front
            return wideAngleCamera
        }

        // simulator or thr request hardware camera doesn't work
        fatalError("Error in handling.")// TODO: show UI instead of a fatal error.
        

    }
    private func toggleRecording() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            updateViews()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    func showAlertMessage(title: String, message: String, actiontitle: String) {
        let endAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let endAction = UIAlertAction(title: actiontitle, style: .default) { (action: UIAlertAction ) in
        }

        endAlert.addAction(endAction)
        present(endAlert, animated: true, completion: nil)
    }

    private func playMovie(url: URL) {
        let player = AVPlayer(url: url)

        if playerView == nil {

            // setup view
            
            let playerView = VideoPlayerView()
            playerView.player = player

            // customize frame
            var frame = view.bounds
            frame.size.height = frame.size.height / 4
            frame.size.width = frame.size.width / 4
            frame.origin.y = view.layoutMargins.top
            playerView.frame = frame
            view.addSubview(playerView)
            self.playerView = playerView
        }
        player.play()
        self.player = player
    }

}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Did start recording: \(fileURL)")

        updateViews()
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving movie: \(error)")
            return
        }
        print("Play Movie!")

        DispatchQueue.main.async {
            self.playMovie(url: outputFileURL)
        }

        //play the movie if no error
        updateViews()
    }

}
