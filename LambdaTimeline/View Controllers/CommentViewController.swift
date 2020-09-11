//
//  CommentViewController.swift
//  LambdaTimeline
//
//  Created by Jesse Ruiz on 12/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CommentViewController: UIViewController {
    
    // MARK: - Properties
    var audioPlayer: AVAudioPlayer?
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    var audioRecorder: AVAudioRecorder?
    var recordURL: URL?
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    var timer: Timer?
    
    // MARK: - Outlets
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelRemaining: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var doneButton: UIButton!
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: .regular)
        timeLabelRemaining.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabelRemaining.font.pointSize, weight: .regular)
        playButton.layer.cornerRadius = playButton.frame.size.width * 0.5
        recordButton.layer.cornerRadius = recordButton.frame.size.width * 0.5
        doneButton.layer.cornerRadius = 10.0
        updateViews()
    }
    
    private func updateViews() {
        let playButtonImage = isPlaying ? UIImage(systemName: "pause.fill") : UIImage(systemName: "play.fill")
        playButton.setImage(playButtonImage, for: .normal)
        
        let elapsedTime = audioPlayer?.currentTime ?? 0
        timeLabel.text = timeFormatter.string(from: elapsedTime)
        
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
        timeSlider.value = Float(elapsedTime)
        
        let recordRed = UIImage(systemName: "circle.fill")?.withTintColor(.systemRed)
        let recordButtonImage = isRecording ? recordRed : UIImage(systemName: "circle.fill")
        recordButton.setImage(recordButtonImage, for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func playButtonPressed(_ sender: UIButton) {
        playToggle()
    }
    
    func playAudio() {
        audioPlayer?.play()
        startTimer()
        updateViews()
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        cancelTimer()
        updateViews()
    }
    
    func playToggle() {
        if isPlaying {
            pauseAudio()
        } else {
            playAudio()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.03,
                                     target: self,
                                     selector: #selector(updateTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func updateTimer(timer: Timer) {
        updateViews()
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        recordToggle()
    }
    
    func record() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        let file = documentsDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        
        print("Record URL: \(file)")
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) else { return }
        
        audioRecorder = try! AVAudioRecorder(url: file, format: format)
        recordURL = file
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
    }
    
    func recordToggle() {
        if isRecording {
            stopRecording()
        } else {
            record()
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
    }
}

extension CommentViewController: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Record error: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordURL = recordURL {
            audioPlayer = try! AVAudioPlayer(contentsOf: recordURL)
        }
    }
}
