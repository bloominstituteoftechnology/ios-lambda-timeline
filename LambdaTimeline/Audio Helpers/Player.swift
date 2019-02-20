//
//  Player.swift
//  SimpleAudioRecorder
//
//  Created by Dillon McElhinney on 2/19/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayerDelegate: AnyObject {
    func playerDidChangeState(_ player: Player)
}

class Player: NSObject, AVAudioPlayerDelegate {
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    weak var delegate: PlayerDelegate?
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    var elapsedTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    var remainingTime: TimeInterval {
        guard let duration = audioPlayer?.duration else { return 0 }
        return duration - elapsedTime
    }
    
    var progress: Float {
        guard let duration = audioPlayer?.duration else { return 0 }
        let progress = elapsedTime/duration
        return Float(progress)
    }
    
    func playPause(file: URL? = nil, data: Data? = nil) {
        if isPlaying {
            pause()
        } else {
            play(file: file, data: data)
        }
    }
    
    func play(file: URL? = nil, data: Data? = nil) {

        if let file = file, audioPlayer?.url != file {
            audioPlayer = try! AVAudioPlayer(contentsOf: file)
            audioPlayer?.delegate = self
        } else if let data = data, audioPlayer?.data != data {
            audioPlayer = try! AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
        }
        audioPlayer?.play()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.notifyDelegate()
        }
        notifyDelegate()
    }
    
    func pause() {
        audioPlayer?.pause()
        timer?.invalidate()
        timer = nil
        notifyDelegate()
    }
    
    // MARK: - AV Audio Player Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        notifyDelegate()
    }
    
    // MARK: - Utility Methods
    private func notifyDelegate() {
        delegate?.playerDidChangeState(self)
    }
}