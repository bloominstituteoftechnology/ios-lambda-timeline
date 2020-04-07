//
//  AudioCommentController.swift
//  AudioComments2
//
//  Created by Chris Gonzales on 4/7/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AudioCommentController {
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var savedComments: [AudioComment] = []
    
    func createComment(author: String){
        let newURL = createNewRecordingURL()
        let newComment = AudioComment(author: author, recording: newURL)
        savedComments.append(newComment)
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(file)")
        
        return file
    }
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")
            
//            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
//
//            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
//                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//            })
//
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
//
//            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    
    func startRecording() {
        let recordingURL = createNewRecordingURL()
                
        // 44.1 KHz = FM radio quality
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: audioFormat) // FIXME: error logic
        audioRecorder?.record()
        
        self.recordingURL = recordingURL
    }

    func stopRecording() {
        audioRecorder?.stop()
    }
}
