//
//  CreateAudioCommentViewController.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/10/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import AVFoundation

class CreateAudioCommentViewController: UIViewController {

    var timer: Timer?
    var audioPlayerController: AudioPlayerController?
    var audioRecorderController: AudioRecorderController?
    
    var timeIntervalFormatter: DateComponentsFormatter?
    
    // MARK: - IBOutlets
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var elapsedTimelabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use a font that won't jump around as values change
        elapsedTimelabel.font = UIFont.monospacedDigitSystemFont(ofSize: elapsedTimelabel.font.pointSize,
                                                          weight: .regular)
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: durationLabel.font.pointSize,
                                                                   weight: .regular)
        updateViews()
    }
    
    func updateViews() {

        recordButton.isSelected = audioRecorderController?.audioRecorder?.isRecording ?? false

        if recordButton.isSelected {
            guard let duration = audioRecorderController?.audioRecorder?.currentTime else { return }
            playButton.isEnabled = false
            durationLabel.text = timeIntervalFormatter?.string(from: duration)
        } else if !recordButton.isSelected {
            playButton.isEnabled = true
            }
        }
        
        deinit {
            timer?.invalidate()
        }
        
        
        // MARK: - Timer
        
        func startTimer() {
            timer?.invalidate()

            timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
                guard let self = self else { return }

                self.updateViews()

            }
        }
        
        func cancelTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        // MARK: - Actions
        
        @IBAction func togglePlayback(_ sender: Any) {

        }
        
        @IBAction func toggleRecording(_ sender: Any) {
            audioRecorderController?.toggleRecording()
            audioRecorderController?.audioRecorder?.delegate = self
            startTimer()
        }
    }

    // MARK: - Extension
    extension CreateAudioCommentViewController: AVAudioRecorderDelegate {
        func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
            if let error = error {
                print("Audio Recorder Error: \(error)")
            }
        }
        
        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            if let recordingURL = audioRecorderController?.recordingURL {
                //audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
            }

            audioRecorderController?.audioRecorder = nil
            cancelTimer()
        }
    }

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
