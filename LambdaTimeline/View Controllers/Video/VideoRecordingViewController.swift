//
//  VideoRecordingViewController.swift
//  LambdaTimeline
//
//  Created by Michael Stoffer on 9/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoRecordingViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSession()
        setUpViews()
    }
    
    func setUpViews() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = videoPreviewView.frame
        videoPreviewView.layer.addSublayer(previewLayer)
    }
    
    func setUpSession() {
        session = AVCaptureSession()
        
        session.sessionPreset = .hd1280x720
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            
            session.beginConfiguration()
            
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            let output = AVCaptureMovieFileOutput()
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            self.output = output
            
            session.commitConfiguration()
            
            session.startRunning()
        
        } catch {
            NSLog("Could not create device input: \(error)")
        }
    }

    @IBAction func record(_ sender: Any) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
        let outputURL = documentDirectory.appendingPathComponent("videoPost.mp4")
            
        output.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        
    }

    @IBAction func done(_ sender: Any) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let error = error {
            NSLog("Finished recording with error: \(error)")
        }
        
        outputURL = outputFileURL
    }
    
    var postController: PostController!
    
    var session: AVCaptureSession!
    var output: AVCaptureMovieFileOutput!
    
    let videoRecordingQueue = DispatchQueue(label: "com.LambdaSchool.LambdaTimeline.VideoRecordingQueue")

    var outputURL: URL?
    
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
}
