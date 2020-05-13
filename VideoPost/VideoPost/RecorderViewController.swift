//
//  RecorderViewController.swift
//  VideoPost
//
//  Created by Jessie Ann Griffin on 5/12/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController {
    
    let videoPostController = VideoPostController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermissionAndShowCamera()
    }

    private func requestPermissionAndShowCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            requestVideoPermission()
       
        case .restricted:
            // parental controls for example are preventing recording
            preconditionFailure("Video is disabled, please review device restrictions.")
       
        case .denied:
            preconditionFailure("Tell the user they can't use the app without giving permissions via Settings > Privacy > Video.")
        
        case .authorized:
            showCamera()
        @unknown default:
            preconditionFailure("A new status code was added that we need to handle")
        }
    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { isGranted in
            guard isGranted else {
                preconditionFailure("UI: Tell user to enable permissions for Video/Camera.")
            }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCamera" {
            if let cameraVC = segue.destination as? CameraViewController {
                cameraVC.videoPostController = videoPostController
            }
        }
    }
}

extension RecorderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videoPostController.collectionOfVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath)
        return cell
    }
    
    
}
