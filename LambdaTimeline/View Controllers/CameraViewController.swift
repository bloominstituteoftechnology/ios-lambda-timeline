//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    
    private lazy var captureSession = AVCaptureSession() //we want this to be executed at a later time
    private lazy var fileOutput = AVCaptureMovieFileOutput() //will initialize later
    private var player: AVPlayer!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: CameraPrviewView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the camera you want to use
        let camera = bestCamera()
        
        //now that I have a camera, try to capture it's input
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else { fatalError("Can't create input from camera.") }
        
        //now we are working for the capture session, which is responsible for orgainziing all of our inputs and outputs
        //setup inputs - verify first
        if captureSession.canAddInput(cameraInput) {
            //if you canADD it.....ADD it
            captureSession.addInput(cameraInput)
        }
        
        //set up outputs
        if captureSession.canAddOutput(fileOutput){
            captureSession.addOutput(fileOutput)
        }
        
        //set the quality video level
        if captureSession.canSetSessionPreset(.hd1920x1080){
            captureSession.canSetSessionPreset(.hd1920x1080)
        }
        
        //Now that I have both the input and output and I've set the quality level, I can now commit/set the configuration
        captureSession.commitConfiguration()
        
        //after configuration add the captureSession to the camerView
        cameraView.session = captureSession
        
        //TODO: ADD PLAYBACK FUNCTION
        
    }
    
    //set up the device you want to use on the camera
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back){
                return device
        }
        
        //could not get a camera
        fatalError("No camera exists - you are running on an old ass phone or a simulator.")
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
    }
    

}
