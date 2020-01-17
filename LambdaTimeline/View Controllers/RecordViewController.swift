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
            audioPlayer.isMeteringEnabled = true
            updateViews()
        }
    }
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playbackButton: UIBarButtonItem!
    
    //MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Methods
    
    private func updateViews() {
        recordButton.isSelected = isRecording
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
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
        playbackButton.isEnabled = true
    }
    
    func play() {
        audioPlayer?.play()
        updateViews()
        // Start timer
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
        // Cancel Timer
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
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

extension RecordViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        // Cancel Timer
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
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Recorder Error: \(error)")
        }
    }
}
