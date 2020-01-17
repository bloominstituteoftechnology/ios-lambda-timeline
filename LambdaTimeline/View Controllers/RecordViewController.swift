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
    
    //MARK: - Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    
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
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
    }
    
    //MARK: - Actions
    
    @IBAction func toggleRecording(_ sender: Any) {
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

extension RecordViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordngURL = recordingURL {
            // audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
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
