//
//  ViewController.swift
//  VideoPosts
//
//  Created by David Wright on 5/12/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestPermissionAndShowCamera()
    }
    
    private func requestPermissionAndShowCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            requestVideoPermission()
            
        case .restricted: // Parental controls, for instance, are preventing recording
            preconditionFailure("Video is disabled, please review device restrictions")
            
        case .denied:
            preconditionFailure("Tell the user they can't use the app without giving permissions via Settings > Privacy > Video")
            
        case .authorized:
            showCamera()
        
        @unknown default:
            preconditionFailure("A new status code was added that we need to handle")
        }
    }

    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { isGranted in
            guard isGranted else {
                preconditionFailure("UI: Tell the user to enable permissions for Video/Camera")
            }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: SegueIdentifiers.showCamera, sender: self)
    }
}

