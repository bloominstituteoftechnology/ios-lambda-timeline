//
//  AudioPlayerController.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/10/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
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
