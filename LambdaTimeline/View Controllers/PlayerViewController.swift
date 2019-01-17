//
//  PlayerViewController.swift
//  LambdaTimeline
//
//  Created by Yvette Zhukovsky on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import Photos
import ImageIO
import AVKit
import AVFoundation
import MobileCoreServices

class PlayerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            self.presentPhotoPickerController()
            
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentPhotoPickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentPhotoPickerController()
        
    }
       
        
  
    
    
    @IBAction func adding(_ sender: Any) {
//        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
//
//        switch authorizationStatus {
//        case .authorized:
//            self.presentPhotoPickerController()
//
//        case .notDetermined:
//
//            PHPhotoLibrary.requestAuthorization { (status) in
//
//                guard status == .authorized else {
//                    NSLog("User did not authorize access to the photo library")
//                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
//                    return
//                }
//
//                self.presentPhotoPickerController()
//            }
//
//        case .denied:
//            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
//        case .restricted:
//            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
//
//        }
//        presentPhotoPickerController()
//
    }
    
   
    
    
        // Do any additional setup after loading the view.
 
    
    @IBOutlet weak var playerView: UIView!

    private func presentPhotoPickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
        
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        self.present(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }
        
    }
    

    



    
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            
            if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                
                let asset = AVAsset(url: url)
                playerItem = AVPlayerItem(asset: asset)
                player = AVPlayer(playerItem: playerItem!)
                playerLayer = AVPlayerLayer(player: player)
                player?.play()
            }
            imagePicker.dismiss(animated: true, completion: nil)
            
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}

