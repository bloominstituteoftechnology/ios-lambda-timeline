//
//  Player.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation

protocol PlayerDelegate {
    func playerStateDidChange()
}

class Player: NSObject {
    var audioPlayer: AVAudioPlayer
    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }
    var delegate: PlayerDelegate?
    override init() {
        self.audioPlayer = AVAudioPlayer()
        super.init()
    }
    
    func load(data: Data)throws {
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer.delegate = self
    }
    
    private func play() {
        audioPlayer.play()
        notifyDelegate()
    }
    
    private func pause() {
        audioPlayer.pause()
        notifyDelegate()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    func notifyDelegate() {
        delegate?.playerStateDidChange()
    }
}
extension Player: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error playing audio file: \(error)")
        }
        
        // TODO: should we propogate this error back, new method in delegate protocol
        notifyDelegate()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // TODO: should we add a delegate protocol method?
        notifyDelegate()
    }
}
