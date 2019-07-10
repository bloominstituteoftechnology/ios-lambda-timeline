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
    private var player: AVPlayer!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: CameraPrviewView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the camera you want to use
        
        
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
