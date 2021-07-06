//
//  AudioRecorderViewController.swift
//  LambdaTimeline
//
//  Created by Isaac Lyons on 12/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioRecorderDelegate {
    func saveRecording(_ recordURL: URL)
}

class AudioRecorderViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    //MARK: Properties
    
    var delegate: AudioRecorderDelegate?
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var recordURL: URL?
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deletePreviousRecording()
    }
    
    //MARK: Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let recordURL = recordURL else { return }
        delegate?.saveRecording(recordURL)
        
        // Clear the recordURL so the file won't be erased in viewDidDisappear
        self.recordURL = nil
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        playStop()
    }
    
    @IBAction func recordTapped(_ sender: UIButton) {
        recordToggle()
    }
    
    //MARK: Private
    
    private func updateViews() {
        let recordButtonTitle = isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
        
        let playButtonTitle = isPlaying ? "Stop Playing" : "Play"
        playButton.setTitle(playButtonTitle, for: .normal)
    }
    
    private func play() {
        audioPlayer?.play()
        updateViews()
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        updateViews()
    }
    
    private func playStop() {
        if isPlaying {
            stopPlayback()
        } else {
            play()
        }
    }
    
    private func deletePreviousRecording() {
        let fileManager = FileManager.default
        
        do {
            if let recordURL = recordURL {
                try fileManager.removeItem(at: recordURL)
                self.recordURL = nil
            }
        } catch {
            NSLog("Error deleting previous recording: \(error)")
        }
    }
    
    private func record() {
        let fileManager = FileManager.default
        
        // Delete the previous recording so they don't pile up in the file system
        deletePreviousRecording()
        
        // Path to save in the Documents directory
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Filename ISO8601 .caf
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        let file = documentsDirectory
            .appendingPathComponent(name)
            .appendingPathExtension("caf")
        
        print(file)
        
        // 44.1 KHz
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try! AVAudioRecorder(url: file, format: format)
        recordURL = file
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        updateViews()
    }
    
    func recordToggle() {
        if isRecording {
            stopRecording()
        } else {
            record()
        }
    }

}

extension AudioRecorderViewController: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            NSLog("Record error: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordURL = recordURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: recordURL)
                audioPlayer?.delegate = self
            } catch {
                NSLog("Error loading recorded audio for playback: \(error)")
            }
        }
        updateViews()
    }
}

extension AudioRecorderViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            NSLog("Playback error: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
}
