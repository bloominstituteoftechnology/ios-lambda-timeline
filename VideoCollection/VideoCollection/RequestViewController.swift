//
//  RequestViewController.swift
//  VideoCollection
//
//  Created by Bhawnish Kumar on 6/3/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit
import AVFoundation
class RequestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // second time authorized
            showCamera()
        case .denied:
            // denied
        let alertController = UIAlertController(title: "Camera Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
          
          alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
              UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          })
          
          alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
          
          present(alertController, animated: true, completion: nil)
        case .notDetermined:
            
        default:
            <#code#>
        }
    }
    
    private func requestCamera() {
        
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            guard granted else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Access Granted", message: "You are able to use the camera now!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
        
            }
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func showCamera() {
        performSegue(withIdentifier: "showCamera", sender: self)
    }
    
}
