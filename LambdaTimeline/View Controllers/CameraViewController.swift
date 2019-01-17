//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Yvette Zhukovsky on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up the capture session
        
        let captureSession = AVCaptureSession()
        
        
        
        // Add Inputs
        
        let camera = bestCamera()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Cannot add camera to capture session.")
        }
        
        captureSession.addInput(cameraInput)
        
        
        
        
        //Ad Outputs
        
        let movieOutput = AVCaptureMovieFileOutput()
        recordOutput = movieOutput
        
        guard  captureSession.canAddOutput(movieOutput) else {
            fatalError("Cannot add movie file output to capture session.")
        }
        captureSession.addOutput(movieOutput)
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        previewView.videoPreviewLayer.session = captureSession
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // This will let the session be ready to record and show video on the camera preview view
        captureSession.startRunning()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateButton()
        }
        
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        DispatchQueue.main.async {
            defer { self.updateButton()}
            
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status != .authorized {
                    
                    NSLog("Please give Video Recording access to your library in settings.")
                    return
                    
                }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                }, completionHandler: { (success, error) in
                    if let error = error {
                        NSLog("Error saving video\(error)")
                    }
                })
            })
            
        }
    }
    
    private func updateButton() {
        
        let isRecording = recordOutput.isRecording
        let buttonImage = isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: buttonImage), for: .normal)
        
        
    }
    
    
    private func newRecordingURL() -> URL {
        //        let fm = FileManager.default
        //        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let tempDir = FileManager.default.temporaryDirectory
        
        return tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    
    
    private func bestCamera() -> AVCaptureDevice {
        // iPHone X or Plus device
        
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default( .builtInWideAngleCamera, for: .video, position: .back ) {
            // Any other iPHone
            return device
        } else {
            // This should only tun on a simulator or device with no camera
            fatalError("Missing back camera device")
        }
        
    }
    
    
    
    var captureSession: AVCaptureSession!
    var recordOutput: AVCaptureMovieFileOutput!
    
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var previewView: CameraPreviewView!
    
    @IBAction func record(_ sender: Any) {
        
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    
    
}
