//
//  ViewController.swift
//  VideoRecording
//
//  Created by Chris Gonzales on 4/8/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestPermissionAndShowCamera()
    }
    
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            
            case .notDetermined:
                requestPermission()
            case .restricted:
                fatalError("Your don't have permission to use the camera, talk to your parent about enabling")
            case .denied:
                fatalError("Show them a link to settings to get access to video")
            case .authorized:
                showCamera()
            @unknown default:
                fatalError("Didn't handle a new state for AVCaptureDevice authorization")
        }
    }

    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                fatalError("Tell user they need to give video permission")
            }
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }
}

