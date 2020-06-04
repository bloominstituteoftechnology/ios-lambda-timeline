//
//  CameraViewController.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/3/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewDelegate {
    func didFinishRecording(to url: URL, lasting length: Double) -> Void
}

class CameraViewController: UIViewController {
    
    lazy private var cameraController = CameraController()
    
    var delegate: CameraViewDelegate?
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraController.setUpCaptureSession()
        cameraView.session = cameraController.captureSession
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        toggleRecording()
    }
    
    private func updateViews() {
        recordButton.isSelected = cameraController.fileOutput.isRecording
    }
    
    private func toggleRecording() {
        let fileOutput = cameraController.fileOutput
                
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            let fileURL = cameraController.newRecordingURL()
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)
        }
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        NSLog("Began recording!")
        
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            NSLog("Error recording: \(error)")
        }
        
        DispatchQueue.main.async {
            self.delegate?.didFinishRecording(to: outputFileURL, lasting : output.recordedDuration.seconds)
            
            self.updateViews()
        }
    }
}
