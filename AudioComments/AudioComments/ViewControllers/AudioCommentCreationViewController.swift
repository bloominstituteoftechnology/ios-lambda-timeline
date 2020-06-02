//
//  AudioCommentCreationViewController.swift
//  AudioComments
//
//  Created by Hunter Oppel on 6/2/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentCreationViewController: UIViewController {
    
    var timer: Timer?
    
    var timeIntervalFormatter: DateComponentsFormatter?
    
//    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
//        let formatting = DateComponentsFormatter()
//        formatting.unitsStyle = .positional
//        formatting.zeroFormattingBehavior = .pad
//        formatting.allowedUnits = [.minute, .second]
//        return formatting
//    }()
    
    var audioPlayerController: AudioPlayerController?
    var audioRecorderController: AudioRecorderController?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        elapsedTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: elapsedTimeLabel.font.pointSize,
                                                                 weight: .regular)
        durationLabel.font = UIFont.monospacedSystemFont(ofSize: durationLabel.font.pointSize,
                                                         weight: .regular)
        
        updateViews()
    }
    
    // MARK: - Timer
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            
            self.updateViews()
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Actions
    
    @IBAction func togglePlayer(_ sender: Any) {
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        toggleRecording()
    }
    
    // MARK: - Private functions
    
    private func toggleRecording() {
        audioRecorderController?.toggleRecording()
        audioRecorderController?.audioRecorder?.delegate = self
        startTimer()
    }
    
    private func updateViews() {
        recordButton.isSelected = audioRecorderController?.audioRecorder?.isRecording ?? false
        
        if recordButton.isSelected {
            guard let duration = audioRecorderController?.audioRecorder?.currentTime else { return }
            playButton.isEnabled = false
            durationLabel.text = timeIntervalFormatter?.string(from: duration)
        } else if !recordButton.isSelected {
            playButton.isEnabled = true
        }
    }
}

// MARK: - Delegations

extension AudioCommentsTableViewController: AudioRecorderControllerDelegate {
    func didNotRecievePermission() {
        print("Microphone access has been blocked.")
        
        let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alertController, animated: true)
    }
}

extension AudioCommentCreationViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = audioRecorderController?.recordingURL {
            print("Finished recording: \(recordingURL.path)")
            
            // TODO: Set audio player to recordingURL
        }
        
        updateViews()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Error recording: \(error)")
        }
        
        updateViews()
    }
}
