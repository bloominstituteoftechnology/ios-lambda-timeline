//
//  ViewController.swift
//  VideoPrototype
//
//  Created by Kenny on 6/3/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

class CameraBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let cameraController = CameraController(delegate: nil)

        cameraController.requestPermissionAndShowCamera { (status) in
            if status {
                self.performSegue(withIdentifier: "ShowCamera", sender: nil)
            }
        }
    }

}
