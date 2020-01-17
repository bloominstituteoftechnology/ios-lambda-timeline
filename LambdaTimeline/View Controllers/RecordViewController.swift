//
//  RecordViewController.swift
//  LambdaTimeline
//
//  Created by Bobby Keffury on 1/17/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    //MARK: - Properties
    var audioRecorder: AVAudioRecorder?
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    
    //MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Methods
    
    private func updateViews() {
        recordButton.isSelected = isRecording
    }
    
    //MARK: - Actions
    
    @IBAction func toggleRecording(_ sender: Any) {
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
