//
//  Recorder.swift
//  LambdaTimeline
//
//  Created by Luqmaan Khan on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

protocol RecorderDelegate {
    func recorderDidChangeState(recorder: Recorder)
    func recorderDidFinishSavingFile(recorder: Recorder, url: URL)
}


//subclass NSObject to have delegate funcitonality
class Recorder: NSObject {
    
   private var audioRecorder: AVAudioRecorder?
    var delegate: RecorderDelegate?
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    override init() {
         super.init()
    }
    
    func record() {
        //create the audio file being recorded
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        //caf is the core audio file format
        let file = documentDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        //create the audio format
        //sample rate in hertz
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        print("Filename: \(file.path)")
        audioRecorder = try! AVAudioRecorder(url: file, format: format)
        audioRecorder?.record()
        //command shift g in finder and paste in the printed file to see if the recordign was made
        audioRecorder?.delegate = self
        notifyDelegate()
    }
    func stop() {
        audioRecorder?.stop() //save to disk
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
        delegate?.recorderDidChangeState(recorder: self)
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
        
        delegate?.recorderDidFinishSavingFile(recorder: self, url: recorder.url)
    }
}
