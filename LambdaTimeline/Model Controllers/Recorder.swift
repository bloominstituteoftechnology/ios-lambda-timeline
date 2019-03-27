//
//  Recorder.swift
//  LambdaTimeline
//
//  Created by Angel Buenrostro on 3/27/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation

protocol RecorderDelegate: AnyObject {
    func recorderDidChangeState(recorder: Recorder)
}


class Recorder: NSObject {
    
    override init() {
        super.init()
        
    }
    
    // record
    func record() {
        
        // Create a recorder
        
        // Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create a file with time stamp
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        // filename.caf
        
        fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        
        //        print("file: \(fileURL.path)")
        
        // 44.1 kHz
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100.0, channels: 2)!
        
        audioRecorder = try! AVAudioRecorder(url: fileURL!, format: format)
        audioRecorder?.delegate = self
        // start recording
        audioRecorder?.record()
        notifyDelegate()
    }
    
    // stop (save the file)
    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
        notifyDelegate()
    }
    
    func toggleRecording() {
        if isRecording {
            stop()
        } else {
            record()
        }
    }
    
    private func notifyDelegate() {
        delegate?.recorderDidChangeState(recorder: self)
    }
    
    // isRecording
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    var fileURL: URL?
    
    weak var delegate: RecorderDelegate?
    
    private var audioRecorder: AVAudioRecorder?
    
}

extension Recorder: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("audioRecorderEncodeErrorDidOccur: \(error)")
        }
        notifyDelegate()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        notifyDelegate()
    }
}
