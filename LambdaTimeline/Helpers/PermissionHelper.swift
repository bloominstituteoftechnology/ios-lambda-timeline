//
//  PermissionHelper.swift
//  LambdaTimeline
//
//  Created by Nick Nguyen on 4/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

extension PostsCollectionViewController {
     func requestPermissionAndShowCamera()  {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            case .notDetermined:
                requestPermission()
            case .restricted:
                fatalError("You don't have permission to use the camera, talk to your parent about enabling")
            case .denied:
                fatalError("Show them a link to settings to get access to video")
            case .authorized: //2nd + run, they've given permission to use the camera
         present(videoRecordingViewController, animated: true, completion: nil)
                break
            @unknown default:
                fatalError("Didn't ")
        }
        
    }
    
     func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else { fatalError("Tell user they need to get video permission") }
            DispatchQueue.main.async {
                //
                self.present(self.videoRecordingViewController, animated: true, completion: nil)
            }
        }
    }
}
