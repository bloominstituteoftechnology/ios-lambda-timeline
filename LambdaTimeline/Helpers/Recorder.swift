//
//  Recorder.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

protocol RecorderDelegate {
    func recorderDidChangeState()
    func recorderDidFinishSavingFile(_ recorder: Recorder, url: URL)
}

class Recorder: NSObject {
    
    var recorder: AVAudioRecorder?
    var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    var delegate: RecorderDelegate?
    
    private func record() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        //44.1 KHz - typical
        let file = documentDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        print(documentDirectory)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        recorder = try! AVAudioRecorder(url: file, format: format)
        
        recorder?.delegate = self
        
        recorder?.record()
        delegate?.recorderDidChangeState()
    }
    
    private func stop() {
        recorder?.stop()
        delegate?.recorderDidChangeState()
    }
    
    func toggleRecord() {
        if isRecording {
            stop()
        } else {
            record()
        }
    }
    
    func cancelRecord() {
        stop()
    }
    
}

extension Recorder: AVAudioRecorderDelegate {
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("audioRecorderEncodeErrorDidOccur: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording")
        delegate?.recorderDidFinishSavingFile(self, url: recorder.url)
    }
}
