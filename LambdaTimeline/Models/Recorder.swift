//
//  Recorder.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation


class Recorder: NSObject {
    
    private var audioRecorder: AVAudioRecorder?
    
    //what functionality do we want to abstract?
    func toggleRecording(){
        
    }
    
    func record(){
        
    }
    
    func stop(){
        audioRecorder?.stop() //we have to stop it and set it to nil to erase
        audioRecorder = nil
    }
}
