//
//  AudioRecorder.swift
//  AudioComments
//
//  Created by Shawn Gee on 5/6/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorder: NSObject {
    
    // MARK: - Public Properties
    
    var isRecording: Bool { recorder?.isRecording ?? false }
    var isPlaying: Bool { player?.isPlaying ?? false }
    
    // MARK: - Private Properties
    
    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var player: AVAudioPlayer?
    
    // MARK: - Public Methods
    
    func startRecording() {
        let recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        recorder = try? AVAudioRecorder(url: recordingURL, format: format)
        recorder?.delegate = self
        
        recorder?.record()
        self.recordingURL = recordingURL
    }
    
    func stopRecording() {
        recorder?.stop()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    // MARK: - Private Methods
    
    private func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let fileURL = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(fileURL)")
        
        return fileURL
    }
    
//    private func requestPermissionOrStartRecording() {
//        switch AVAudioSession.sharedInstance().recordPermission {
//        case .undetermined:
//            AVAudioSession.sharedInstance().requestRecordPermission { granted in
//                guard granted == true else {
//                    print("We need microphone access")
//                    return
//                }
//
//                print("Recording permission has been granted!")
//                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
//            }
//        case .denied:
//            print("Microphone access has been blocked.")
//
//            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
//
//            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
//                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//            })
//
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
//
//            present(alertController, animated: true, completion: nil)
//        case .granted:
//            startRecording()
//        @unknown default:
//            break
//        }
//    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if flag, let recordingURL = recordingURL  {
//            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
//        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("⚠️ Audio Recorder Error: \(error)")
        }
    }
}

extension AudioRecorder: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("⚠️ Audio Player Error: \(error)")
        }
    }
}
