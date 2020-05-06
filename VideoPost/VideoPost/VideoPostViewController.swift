//
//  VideoPostViewController.swift
//  VideoPost
//
//  Created by Shawn Gee on 5/6/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostViewController: UIViewController {

    // MARK: - Private Properties
    
    private var shouldShowCamera = true
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowCamera {
            requestPermissionAndShowCamera()
        }
    }

    
    // MARK: - Private Methods
    
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined: // First time we've requested access
            requestPermission()
        case .restricted: // Parental controls prevent user from using the camera/microphone
            fatalError("Tell user they need to request permission from parent/guardian (UI)")
        case .denied:
            fatalError("Tell user to enable in Settings: Popup from Audio to do this, or use a custom view")
        case .authorized:
            showCamera()
        @unknown default:
            fatalError("Handle new case for authorization")
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (accessGranted) in
            guard accessGranted else {
                fatalError("Tell user to enable in Settings: Popup from Audio to do this, or use a custom view")
            }
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ShowCameraSegue", sender: self)
        shouldShowCamera = false
    }
}

