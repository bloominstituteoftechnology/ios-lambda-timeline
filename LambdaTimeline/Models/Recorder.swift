//
//  Recorder.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation

protocol RecorderDelegate: AnyObject { //because we subclassed NSObject, the delegate should conform to AnyObject
    func recorderDidChangeState(recorder: Recorder)
}

class Recorder: NSObject {
    
    private var audioRecorder: AVAudioRecorder?
    var fileURL: URL?
    weak var delegate: RecorderDelegate?
    
    //this is to help with the toggle function
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    //since we are subclassing NSObject we have to initialize the super.init
//    override init(){
//        super.init()
//    }
    
    //what functionality do we want to abstract?
    func toggleRecording(){
        if isRecording {
            stop()
        } else {
            record()
        }
    }
    
    func record(){
        //create a document directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! //force unwrapping/ should unwrap safely
        print("Doc: \(documentDirectory)")
        
        //give the directory a file name ( that will be random, or just not hard coded ) make a variable and store its reference for later use
        let fileName = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        fileURL = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("caf")
        
        //format the AudioFormat: khz & channels & initialize avaudioRecorder with the khz and format
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try! AVAudioRecorder(url: fileURL!, format: format)
        
        //set the audioRecorder delegate here
        audioRecorder?.delegate = self
        
        //RECORD
        audioRecorder?.record()
        
        //notifiyDelegate
        notifyDelegate()
    }
    
    func stop(){
        audioRecorder?.stop() //we have to stop it and set it to nil to erase
        audioRecorder = nil
        notifyDelegate()
    }
    
  //create a function that will notifiy delegate when recorder has changed/has been triggered
    func notifyDelegate(){
        delegate?.recorderDidChangeState(recorder: self)
    }
}

extension Recorder: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error with audioRecorder: \(String(describing: error?.localizedDescription)), MOREDetailed: \(String(describing: error))")
        
        //notify delegate
        notifyDelegate()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //notifiy delegate
        notifyDelegate()
    }
}
