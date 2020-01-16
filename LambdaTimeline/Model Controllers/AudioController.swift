//
//  AudioController.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_204 on 1/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

class AudioController {

    var audioPlayer: AVAudioPlayer?

    var timer: Timer?

    private func loadAudio() {
        let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!

        audioPlayer = try! AVAudioPlayer(contentsOf: songURL) // FIXME: catch error and print
    }

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    func play() {
        audioPlayer?.play()
        startTimer()
    }

    func pause() {
        audioPlayer?.pause()
        cancelTimer()
    }

    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    private func startTimer() {
        cancelTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.03,
                                     target: self,
                                     selector: #selector(updateTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc private func updateTimer(timer: Timer) {

    }

    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Record APIs

    var audioRecorder: AVAudioRecorder?
    var recordURL: URL?

    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }

    func record() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])

        let file = documents.appendingPathComponent(name).appendingPathExtension("caf")
        recordURL = file

        print("record: \(file)")

        // 44.1 KHz 44,100 samples per second
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)! // FIXME: error handling

        audioRecorder = try! AVAudioRecorder(url: file, format: format) // FIXME: try!
        audioRecorder?.record()
    }

    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
    }

    func recordToggle() {
        if isRecording {
            stop()
        } else {
            record()
        }
    }

}
