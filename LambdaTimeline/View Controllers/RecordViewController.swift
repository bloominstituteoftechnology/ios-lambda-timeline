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
    
    weak var timer: Timer?
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    //MARK: - Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reverseTimeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: .regular)
        reverseTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: reverseTimeLabel.font.pointSize, weight: .regular)
        
        updateViews()
    }
    
    //MARK: - Methods
    
    private func updateViews() {
        recordButton.isSelected = isRecording
        playbackButton.isSelected = isPlaying
        
        let elapsedRecordTime = audioRecorder?.currentTime ?? 0
        let elapsedPlayTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0
        let timeRemaining = duration - elapsedPlayTime
        
        timeLabel.text = timeFormatter.string(from: elapsedRecordTime)
        reverseTimeLabel.text = timeFormatter.string(from: timeRemaining)
    }
    
    func startRecording() {
        let doctuments = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = doctuments.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        recordingURL = file
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        audioRecorder = try? AVAudioRecorder(url: file, format: format)
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
        playbackButton.isEnabled = false
        saveButton.isEnabled = false
        cleanSlate()
        startTimer()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
        playbackButton.isEnabled = true
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
        if timeLabel.alpha == 1 {
            reverseTimeLabel.alpha = 1
            timeLabel.alpha = 0
        } else {
            reverseTimeLabel.alpha = 0
            timeLabel.alpha = 1
        }
    }
    
    func cleanSlate() {
        timeLabel.alpha = 1
        reverseTimeLabel.alpha = 0
        timeLabel.text = "00:00"
    }
    
    func save(recording: URL) {
        //Fill this and move it to the controller.
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func toggleRecording(_ sender: Any) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let recordingURL = recordingURL else { return }
        
        let savedAlert = UIAlertController(title: "Message Saved!", message: "", preferredStyle: .alert)
        savedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.save(recording: recordingURL)
            self.cleanSlate()
        }))
        self.present(savedAlert, animated: true, completion: nil)
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveSegue" {
            if let detailVC = segue.destination as? ImagePostDetailTableViewController {
                guard let recordingURL = recordingURL, let name = nameTextField.text else { return }
                detailVC.recordingURL = recordingURL
                detailVC.name = name
            }
        }
    }
}

extension RecordViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}

extension RecordViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordngURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordngURL)
            self.recordingURL = nil
            updateViews()
            cancelTimer()
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Recorder Error: \(error)")
        }
    }
}
