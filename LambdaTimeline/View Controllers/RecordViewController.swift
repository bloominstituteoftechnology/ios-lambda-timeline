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
    weak var timer: Timer?
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
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    // MARK: - IBAction
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Recording saved", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.cleanSlate()
        }))
        self.present(ac, animated: true, completion: nil)
    }
    
    
    // MARK: - View LifeCycle
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
    
    func startRecording() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        recordingURL = file
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        audioRecorder = try? AVAudioRecorder(url: file, format: format)
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
        playButton.isEnabled = false
        saveButton.isEnabled = false
        cleanSlate()
        startTimer()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
        playButton.isEnabled = true
        saveButton.isEnabled = true
        cancelTimer()
        flipTimer()
    }
    
    func play() {
        audioPlayer?.play()
        updateViews()
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
        })
    }
    
    func flipTimer() {
        if durationLabel.alpha == 1 {
            remainingTimeLabel.alpha = 1
            durationLabel.alpha = 0
        } else {
            remainingTimeLabel.alpha = 0
            durationLabel.alpha = 1
        }
    }
    
    func cleanSlate() {
        durationLabel.alpha = 1
        remainingTimeLabel.alpha = 0
        durationLabel.text = "00:00"
    }
}

// MARK: - Extensions
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
