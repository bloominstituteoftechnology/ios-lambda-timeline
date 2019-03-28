//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Angel Buenrostro on 3/28/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage

class CameraViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the capture session
        let camera = bestCamera()
        
        // Inputs
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Can't create the input from the camera, do something else instead")
        }
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("This session can't handle this type of input")
        }
        captureSession.addInput(cameraInput)
        
        // Outputs
        
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record to file")
        }
        captureSession.addOutput(fileOutput)
        
        // Settings
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.canSetSessionPreset(.hd1920x1080)
        }
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        fatalError("No cameras on the device")
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            
            // Video file isn't finished saving yet...
            
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
        
    }
    
    // Gives a unique name for the URL recording path based on the current time
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    var storage = Storage.storage()
    var downloadURL: URL?
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
}



extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        // Saving video to Firebase storage
        let storageRef = storage.reference()
        
        let videoRef = storageRef.child(outputFileURL.absoluteString)
        
        let uploadTask = videoRef.putFile(from: outputFileURL, metadata: nil) { (nil, error) in
            if let error = error {
                print("Error uploading video to Firebase: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print("Error returning download url from uploaded video: \(error.localizedDescription)")
                    } else {
                        self.downloadURL = url
                    }
                })
            }
        }
        
        // How to save video to photo library
//        PHPhotoLibrary.requestAuthorization { (status) in
//            guard status == .authorized else {
//                fatalError("Handle situation where user declines photo library access")
//            }
//            PHPhotoLibrary.shared().performChanges({
//                // Create a request to save video
//                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
//
//            }, completionHandler: { (success, error) in
//                if let error = error {
//                    print("Error saving video: \(error.localizedDescription)")
//                } else {
//                    print("Saving video succeeded: \(outputFileURL)")
//                }
//            })
//        }
        
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
}
