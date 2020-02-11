//
//  AudioManager.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//
import AVFoundation
import Foundation

protocol AudioManagerDelegate: class {
    func isRecording()
    func doneRecording(with url: URL)
}

class AudioManager: NSObject {
    
    
    var audioRecorder: AVAudioRecorder?
    weak var delegate: AudioManagerDelegate?
    var recordingURL: URL? 
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    func toggleRecordingMode() {
        if isRecording {
            stopRecording()
        } else {
            requestRecordPermission()
        }
    }
    
    private func startRecording() {
        guard let recordingURL = makeNewRecordingURL() else { return }
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) else { return }
        do {
            self.recordingURL = recordingURL
            audioRecorder = try AVAudioRecorder(url: recordingURL, format: format)
            audioRecorder?.record()
            delegate?.isRecording()
        } catch {
            NSLog("Audio Recording error: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        guard let url = recordingURL else { return }
        delegate?.doneRecording(with: url)
    }
    
    private func requestRecordPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            DispatchQueue.main.async {
                guard granted else {
                    fatalError("we need microphone access")
                }
                self.startRecording()
            }
        }
    }
    
    private func makeNewRecordingURL() -> URL? {
        guard let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        let url = document.appendingPathComponent(name).appendingPathExtension("caf")
        return url
    }
}
