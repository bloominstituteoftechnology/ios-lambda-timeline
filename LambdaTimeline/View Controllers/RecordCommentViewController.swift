//
//  RecordCommentViewController.swift
//  LambdaTimeline
//
//  Created by John Kouris on 1/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordCommentViewController: UIViewController {
    
    var postController: PostController!
    var post: Post!
    
    var recordButton = UIButton()
    var playButton = UIButton()
    var addCommentButton = UIButton()
    
    weak var timer: Timer?
    
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureRecordButton()
        configurePlayButton()
        configureAddCommentButton()
    }
    
    // MARK: - Timer
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            guard let audioPlayer = self.audioPlayer else { return }
            
            audioPlayer.updateMeters()
        })
    }
    
    // MARK: - Playback
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func play() {
        audioPlayer?.play()
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        cancelTimer()
    }
    
    @objc func togglePlayback() {
        if isPlaying {
            playButton.setTitle("Play", for: .normal)
            playButton.backgroundColor = .systemBlue
            pause()
        } else {
            playButton.backgroundColor = .systemGray
            playButton.setTitle("Pause", for: .normal)
            play()
        }
    }
    
    // MARK: - Recording
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
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
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    @objc func toggleRecording() {
        if isRecording {
            recordButton.setTitle("Record", for: .normal)
            recordButton.backgroundColor = .systemBlue
            stopRecording()
        } else {
            recordButton.backgroundColor = .systemRed
            recordButton.setTitle("Stop", for: .normal)
            startRecording()
        }
    }
    
    // MARK: - Configure Layout
    
    func configureRecordButton() {
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Record", for: .normal)
        recordButton.backgroundColor = .systemBlue
        recordButton.layer.cornerRadius = 25
        
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -70),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            recordButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configurePlayButton() {
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Play", for: .normal)
        playButton.backgroundColor = .systemBlue
        playButton.layer.cornerRadius = 25
        
        playButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 70),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configureAddCommentButton() {
        view.addSubview(addCommentButton)
        addCommentButton.translatesAutoresizingMaskIntoConstraints = false
        addCommentButton.setTitle("Post Comment", for: .normal)
        addCommentButton.backgroundColor = .systemBlue
        addCommentButton.layer.cornerRadius = 25
        
        NSLayoutConstraint.activate([
            addCommentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            addCommentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            addCommentButton.heightAnchor.constraint(equalToConstant: 50),
            addCommentButton.widthAnchor.constraint(equalToConstant: 240)
        ])
    }
    
}

// MARK: - Audio extensions

extension RecordCommentViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
    
}

extension RecordCommentViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
            self.recordingURL = nil
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Recorder Error: \(error)")
        }
    }
}
