//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    
    private lazy var captureSession = AVCaptureSession() //we want this to be executed at a later time
    private var player: AVPlayer!
    
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
    }
    

}
