//
//  VideoRecordingViewController.swift
//  VideoRecording
//
//  Created by Chris Gonzales on 4/8/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class VideoRecordingViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var lightButton: UIButton!
    
    @IBAction func cameraTapped(_ sender: UIButton) {
    }
    @IBAction func flipTapped(_ sender: UIButton) {
    }
    @IBAction func lightTapped(_ sender: UIButton) {
    }
    
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
