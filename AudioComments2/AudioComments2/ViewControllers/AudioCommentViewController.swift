//
//  AudioCommentViewController.swift
//  AudioComments
//
//  Created by Chris Gonzales on 4/7/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentViewController: ViewController, AVAudioRecorderDelegate {
    
    // MARK: -Properties
    
    var audioCommentController: AudioCommentController?
    var isRecording: Bool {
        guard let audioCommentController = audioCommentController,
            let audioRecorder = audioCommentController.audioRecorder else { return false}
        return audioRecorder.isRecording
    }
    
    // MARK: -Outlets
    
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    
    // MARK: -Actions
    
    @IBAction func recordTapped(_ sender: UIButton) {
        guard let audioCommentController = audioCommentController else { return }
        if isRecording {
            audioCommentController.stopRecording()
            updateViews()
        } else {
            audioCommentController.requestPermissionOrStartRecording()
            updateViews()
        }
    }
    @IBAction func cancelTapped(_ sender: UIButton) {
    }
    
    //MARK: -View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let audioCommentController = audioCommentController,
            let audioRecorder = audioCommentController.audioRecorder else { return }
        audioRecorder.delegate = self
    }
    
    private func updateViews() {
        recordButton.isSelected = isRecording
    }
    
    //MARK: - Private Methods
    
    
}
