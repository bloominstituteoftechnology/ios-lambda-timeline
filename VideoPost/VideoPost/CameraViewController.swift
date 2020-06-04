//
//  CameraViewController.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/3/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    lazy private var cameraController = CameraController()
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        toggleRecording()
    }
    
    private func updateViews() {
        recordButton.isSelected = cameraController.fileOutput.isRecording
    }
    
    private func toggleRecording() {
        let fileOutput = cameraController.fileOutput
        let fileURL = cameraController.newRecordingURL()
                
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)
        }
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        <#code#>
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        <#code#>
    }
}
