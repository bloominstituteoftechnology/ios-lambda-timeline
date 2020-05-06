//
//  LandingViewController.swift
//  Video
//
//  Created by Wyatt Harrell on 5/6/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import AVFoundation

class LandingViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var myVideosButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    private func updateViews() {
        recordButton.layer.cornerRadius = 8
        myVideosButton.layer.cornerRadius = 8
    }
    
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            case .notDetermined: // First time we've requested access
                requestPermission()
            case .restricted: // Parental controls prevent user from using the camera / mic
                fatalError("Tell user they need to reqquest permission from parent (UIAlert)")
            case .denied:
                fatalError("Tell the user to enable in settings")
            case .authorized:
                showCamera()
            default:
                fatalError("Handle new case for authorization")
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (isGranted) in
            guard isGranted else { fatalError("Tell the user to enable in settings") }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "PresentCameraSegue", sender: self)
    }
    
    
    
    
    
    
    
    
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        requestPermissionAndShowCamera()
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
