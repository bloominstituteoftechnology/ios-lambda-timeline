//
//  AudioPlayerController.swift
//  AudioComments
//
//  Created by Hunter Oppel on 6/2/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayerController {
    var audioPlayer: AVAudioPlayer?
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    private func play() {
        audioPlayer?.play()
    }
    
    private func pause() {
        audioPlayer?.pause()
    }
}
