//
//  CreateAudioCommentViewController.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/10/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import AVFoundation

protocol CreateCommentDelegate {
    func didSaveAudioComment(_ url: URL) -> Void
}

class CreateAudioCommentViewController: UIViewController {

    var timer: Timer?
    var audioPlayerController: AudioPlayerController?
    var audioRecorderController: AudioRecorderController?
    
    var timeIntervalFormatter: DateComponentsFormatter?
    
    var delegate: CreateCommentDelegate?
    
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
            let duration = audioRecorderController?.audioRecorder?.currentTime ?? 0
            playButton.isEnabled = false
            durationLabel.text = timeIntervalFormatter?.string(from: duration)
        } else if !recordButton.isSelected {
            playButton.isEnabled = true
            }
        
        playButton.isSelected = audioPlayerController?.audioPlayer?.isPlaying ?? false

        if playButton.isSelected {
            recordButton.isEnabled = false

            let duration = audioPlayerController?.audioPlayer?.duration ?? 0
            let elapsedTime = audioPlayerController?.audioPlayer?.currentTime ?? 0
            let timeRemaining = round(duration) - elapsedTime

            elapsedTimelabel.text = timeIntervalFormatter?.string(from: elapsedTime)
            durationLabel.text = timeIntervalFormatter?.string(from: timeRemaining)

            timeSlider.minimumValue = 0
            timeSlider.maximumValue = Float(duration)
            timeSlider.value = Float(elapsedTime)
        } else if !playButton.isSelected {
            recordButton.isEnabled = true
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
        
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let recordingURL = audioRecorderController?.recordingURL else { return }
        delegate?.didSaveAudioComment(recordingURL)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func togglePlayback(_ sender: Any) {
            audioPlayerController?.togglePlayback()
            audioPlayerController?.audioPlayer?.delegate = self
            updateViews()
            
            switch playButton.isSelected {
            case true:
                startTimer()
            default:
                cancelTimer()
            }
        }
        
        @IBAction func toggleRecording(_ sender: Any) {
            audioRecorderController?.toggleRecording()
            audioRecorderController?.audioRecorder?.delegate = self
            updateViews()
            
            switch recordButton.isSelected {
            case true:
                startTimer()
            default:
                cancelTimer()
            }
        }
    }

    // MARK: - Extension
    extension CreateAudioCommentViewController: AVAudioRecorderDelegate {
        func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
            if let error = error {
                print("Audio Recorder Error: \(error)")
            }
            
            cancelTimer()
            updateViews()
        }
        
        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            if let recordingURL = audioRecorderController?.recordingURL {
                do {
                    audioPlayerController?.audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
                } catch {
                    print("Error setting audio plyaer: \(error)")
                }
            }

            audioRecorderController?.audioRecorder = nil
            cancelTimer()
            updateViews()
        }
    }

    extension CreateAudioCommentViewController: AudioRecorderControllerDelegate {
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

extension CreateAudioCommentViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        cancelTimer()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error during playback: \(error)")
        }

        cancelTimer()
        updateViews()
    }
}
