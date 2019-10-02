//
//  VideoDetailViewController.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestCameraPermission()
    }
    
    private func requestCameraPermission() {
        // get permission, show camera if we have it
        // error condition with lack of permission/restricted
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            requestCameraAccess()
        case .restricted:
            fatalError("inform user cannot use app due to parental restriction")
        case .denied:
            fatalError("ask user to enable camera in Setting> Privacy > Camera")
        case .authorized:
            showCamera()
        }
    }
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if !granted {
                fatalError("please request user to enable camera usage in Setting > Privacy > camera")
            }
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    private func showCamera() {
        performSegue(withIdentifier: "CameraModalSegue", sender: self)
    }
    

//    func playMovie(url: URL) {
//         player = AVPlayer(url: url)
//
//         let playerLayer = AVPlayerLayer(player: player)
//         var topRect = self.view.bounds
//         topRect.size.height /= 4
//         topRect.size.width /= 4
//         topRect.origin.y = view.layoutMargins.top
//
//         playerLayer.frame = topRect
//         view.layer.addSublayer(playerLayer)
//
//         player.play()
//     }

}
