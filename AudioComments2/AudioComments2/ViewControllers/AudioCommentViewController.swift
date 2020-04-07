//
//  AudioCommentViewController.swift
//  AudioComments
//
//  Created by Chris Gonzales on 4/7/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentViewController: ViewController {
    
    // MARK: -Properties
    
    let audioCommentController = AudioCommentController()
    var isRecording: Bool {
        guard let audioRecorder = audioCommentController.audioRecorder else { return false}
        return audioRecorder.isRecording
    }

    // MARK: -Outlets
    
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    
    // MARK: -Actions
    
    @IBAction func recordTapped(_ sender: UIButton) {
    }
    @IBAction func cancelTapped(_ sender: UIButton) {
    }
    
   

}
