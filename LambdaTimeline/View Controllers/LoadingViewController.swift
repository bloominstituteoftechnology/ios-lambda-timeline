//
//  LoadingViewController.swift
//  LambdaTimeline
//
//  Created by Bobby Keffury on 1/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class LoadingViewController: UIViewController {

    //MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        requestPermissionAndShowCamera()
    }
    
    //MARK: - Methods
    
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            requestPermission()
        case .restricted:
            fatalError("Video is disabled for parental controls")
        case .denied:
            fatalError("Tell user they need to enable Privacy for Video/Camera/Microphone")
        case .authorized :
            showCamera()
        default:
            fatalError("A new status was added that we need to handle")
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                DispatchQueue.main.async {
                    self.showCamera()
                }
            } else {
                fatalError("Tell user they need to enable Privacy for Video/Camera/Microphone")
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "showCamera", sender: self)
    }

}
