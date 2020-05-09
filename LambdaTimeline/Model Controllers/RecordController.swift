//
//  RecordController.swift
//  LambdaTimeline
//
//  Created by Vici Shaweddy on 1/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import AVFoundation

class RecordController: NSObject {
    
    // MARK: - Properties
    var audioRecorder: AVAudioRecorder?
    var audioURL: URL?
    
    // MARK: - Recording
    var isRecording: Bool {
        self.audioRecorder?.isRecording ?? false
    }
    
    func startRecording() {
        try! AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        self.audioURL = file
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    
        do {
            self.audioRecorder = try AVAudioRecorder(url: file, format: format)
            self.audioRecorder?.isMeteringEnabled = true
        } catch {
            print("Error start recording: \(error)")
        }

        self.audioRecorder?.delegate = self
        self.audioRecorder?.prepareToRecord()
        self.audioRecorder?.record()
        print("Is recording: \(self.isRecording)")
    }
    
    func stopRecording() {
        self.audioRecorder?.stop()
        self.audioRecorder = nil
    }
}

extension RecordController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Did finish recording: \(String(describing: self.audioURL))")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Recorder Error: \(error)")
        }
    }
}
