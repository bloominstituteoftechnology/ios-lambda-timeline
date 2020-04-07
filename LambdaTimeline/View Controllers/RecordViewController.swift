//
//  RecordViewController.swift
//  LambdaTimeline
//
//  Created by Enrique Gongora on 4/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    // MARK: - Variables
    weak var time: Timer?
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.delegate = self
            updateViews()
        }
    }
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var saveButtonTapped: UIBarButtonItem!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Functions
    private func updateViews() {
        record.isSelected = isRecording
        playButton.isSelected = isPlaying
        
        let elapsedRecordTime = audioRecorder?.currentTime ?? 0
        let elapsedPlayTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0
        let timeRemaining = duration - elapsedPlayTime
        
        durationLabel.text = timeFormatter.string(from: elapsedRecordTime)
        remainingTimeLabel.text = timeFormatter.string(from: timeRemaining)
        
    }
    
}

extension RecordViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio player error: \(error)")
        }
    }
}

extension RecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
            self.recordingURL = nil
            updateViews()
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio recorder error: \(error)")
        }
    }
}
