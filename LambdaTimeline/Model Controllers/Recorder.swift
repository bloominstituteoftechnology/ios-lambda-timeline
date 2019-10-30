//
//  Recorder.swift
//  LambdaTimeline
//
//  Created by Ciara Beitel on 10/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation

protocol RecorderDelegate {
    func recorderDidChangeState(_ recorder: Recorder)
    func recorderDidFinishSavingFile(_ recorder: Recorder, url: URL)
}

class Recorder: NSObject {
    
    private var audioRecorder: AVAudioRecorder?
    var delegate: RecorderDelegate?
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    override init() {
        super.init()
    }
    
    func record() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        // <date>.caf
        let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("caf")
        print("Filename: \(fileURL.path)")
        
        // 44.1 kHz
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            print("record: \(fileURL.path)")
            audioRecorder = try AVAudioRecorder(url: fileURL, format: audioFormat)
            audioRecorder?.delegate = self
        } catch {
            print("AVAudioRecorder Error: \(error)")
        }
        
        audioRecorder?.record()
        notifyDelegate()
    }
    
    func stop() {
        audioRecorder?.stop()
        notifyDelegate()
    }
    
    func toggleRecording() {
        if isRecording {
            stop()
        } else {
            record()
        }
    }
    
    func notifyDelegate() {
        delegate?.recorderDidChangeState(self)
    }
}

extension Recorder: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("AVAudioRecorder Error: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.recorderDidFinishSavingFile(self, url: recorder.url)
    }
}
