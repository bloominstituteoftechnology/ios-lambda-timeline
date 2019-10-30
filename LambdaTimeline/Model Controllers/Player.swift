//
//  Player.swift
//  
//
//  Created by Ciara Beitel on 10/30/19.
//

import AVFoundation

protocol PlayerDelegate {
    func playerDidChangeState(player: Player)
}

class Player: NSObject {
    
    var audioPlayer: AVAudioPlayer?
    var delegate: PlayerDelegate?
    var url: URL
    var timer: Timer?
    
    var timeElapsed: TimeInterval {
        audioPlayer?.currentTime ?? 0.0
    }

    var duration: TimeInterval {
        audioPlayer?.duration ?? 0.0
    }

    var timeRemaining: TimeInterval {
        duration - timeElapsed
    }
    
    init(url: URL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!) {
        self.url = url
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("AudioPlayer Error: \(url)")
        }
        super.init()
        audioPlayer?.delegate = self
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    func play() {
        audioPlayer?.play()
        delegate?.playerDidChangeState(player: self)
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        delegate?.playerDidChangeState(player: self)
        cancelTimer()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func startTimer() {
        cancelTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func updateTimer(timer: Timer) {
        delegate?.playerDidChangeState(player: self)
    }
}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("AVAudioError: \(String(describing: error))")
        cancelTimer()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playerDidChangeState(player: self)
        cancelTimer()
    }
}
