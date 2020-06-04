//
//  CameraViewController.swift
//  VideoPrototype
//
//  Created by Kenny on 6/3/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    lazy var cameraController = CameraController(delegate: self)
    var playerView: VideoPlayerView!

    @IBOutlet var cameraView: CameraPreviewView!
    @IBOutlet var recordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        cameraController.setupCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraController.captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraController.captureSession.stopRunning()
    }

    private func updateViews() {
        recordButton.isSelected = cameraController.isRecording
    }

    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecording()
    }

    private func toggleRecording() {
        if cameraController.isRecording {
            cameraController.stopRecording()
        } else {
            cameraController.startRecording(to: self)
        }

    }
}

extension CameraViewController: CameraUIDelegate {

    func playMovie(url: URL) {
        let player = AVPlayer(url: url)
        if playerView == nil {
            // setup view
            let playerView = VideoPlayerView()
            playerView.player = player
            // customize the frame
            var frame = view.bounds
            frame.size.height = frame.size.height / 1.5
            frame.size.width = frame.size.width / 1.5
            frame.origin.y = view.layoutMargins.top
            playerView.frame = frame
            playerView.center.x = view.center.x
            view.addSubview(playerView)
            self.playerView = playerView
        }
        player.play()
        playerView.player = player
    }

}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started Recording to file: \(fileURL)")
        updateViews()
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        playMovie(url: outputFileURL)
        updateViews()
    }

}
