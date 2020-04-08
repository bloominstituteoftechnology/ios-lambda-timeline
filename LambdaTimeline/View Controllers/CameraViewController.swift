//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Keri Levesque on 4/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation // nothing will work without this

class CameraViewController: UIViewController {

    //MARK: Properties
    
    //MARK: Outlets
    @IBOutlet weak var cameraPreview: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    //MARK: View Lifecyclegit p
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
