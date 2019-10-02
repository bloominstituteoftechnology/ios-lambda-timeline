//
//  AudioPlayer.swift
//  LambdaTimeline
//
//  Created by Luqmaan Khan on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

//this is to check did we change the state?
protocol AudioPlayerDelegate {
    func playerDidChangeState(player: AudioPlayer)
}

class AudioPlayer: NSObject {
    //handles all the audio playing functions in a clean way
    
    
    var delegate: AudioPlayerDelegate?
    var audioPlayer: AVAudioPlayer!
    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }
    
    var timer: Timer?
    
    var elapsedTIme: TimeInterval {
        return audioPlayer.currentTime
    }
    
    var timeRemaining: TimeInterval {
        return duration - elapsedTIme
    }
    
    var duration: TimeInterval {
        return audioPlayer.duration
    }
    
    override init() {
        
        //setup
        self.audioPlayer = AVAudioPlayer.init()
        //load the url for the mp3
        super.init()
        let song = Bundle.main.url(forResource: "voiceRecording", withExtension: "mp3")!
        try! load(url: song)
    }
    
    func load(url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer.delegate = self
    }
    
    
    func play() {
        audioPlayer.play()
        //notify the delegate of changed state
        startTimer()
        notifyDelegate()
    }
    
    func pause() {
        audioPlayer.pause()
        //notify the delegate of changed state
        stopTimer()
        notifyDelegate()
    }
    
    //helper to create a timer
    private func startTimer() {
        //stop existing timers first
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (_) in
            self.notifyDelegate()
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    //helper func
    func notifyDelegate() {
        delegate?.playerDidChangeState(player: self)
    }
    
    func playPause() {
        //figure out based on state what to do
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
}

//what if there are interruptions in the audio?
extension AudioPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error playing audio file: \(error)")
        }
        notifyDelegate()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        notifyDelegate()
    }
}
