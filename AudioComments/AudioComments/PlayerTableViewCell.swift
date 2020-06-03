//
//  PlayerTableViewCell.swift
//  AudioComments
//
//  Created by Bhawnish Kumar on 6/2/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit
import AVFoundation
class PlayerTableViewCell: UITableViewCell {

   var audioClip: URL!

        var audioPlayer: AVAudioPlayer? {
            didSet {
                // Using a didSet allows us to make sure we don't forget to set the delegate
                audioPlayer?.delegate = self
            }
        }

        var isPlaying: Bool {
            audioPlayer?.isPlaying ?? false
        }

        deinit {
            cancelTimer()
        }
        
        func loadAudio(_ audioClip: URL) {
            // DRM will fail this call
            audioPlayer = try? AVAudioPlayer(contentsOf: audioClip)
        }

        func prepareAudioSession() throws {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try session.setActive(true, options: []) // can fail if on a phone call, for instance
        }

        private func play() {
            if audioPlayer == nil {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioClip)
                } catch {
                    print("Couldn't load clip; we tried: \(audioClip.absoluteString)")
                    return
                }
            }
            audioPlayer?.play()
            startTimer()
            updateViews()
        }

        private func pause() {
            audioPlayer?.pause()
            cancelTimer()
            updateViews()
        }

        // MARK: - Actions

        @IBAction func playPauseButton(_ sender: UIButton) {
            if isPlaying { // isPlaying == true
                pause()
            } else {
                play()
            }
        }

        @IBAction func playSlider(_ sender: UISlider) {
            if isPlaying {
                pause() // Don't want to be playing and scrubbing at the same time.
            }

            audioPlayer?.currentTime = TimeInterval(clipSlider.value)
            updateViews()
        }

        // MARK: - Outlets
        @IBOutlet weak var playPauseButtonOutlet: UIButton!
        
        @IBOutlet weak var clipSlider: UISlider!

        // MARK: - Timer

        var timer: Timer?

        func startTimer() {
            timer?.invalidate() // Cancel a timer before you start a new one!

            timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
                guard let self = self else { return }

                self.updateViews()
            }
        }

        func cancelTimer() {
            timer?.invalidate()
            timer = nil
        }

        // MARK: - Private
        private func updateViews() {
            // This is what changes the button UI
            playPauseButtonOutlet.isSelected = isPlaying

            let currentTime = audioPlayer?.currentTime ?? 0.0
            let duration = audioPlayer?.duration ?? 0.0

            clipSlider.minimumValue = 0
            clipSlider.maximumValue = Float(duration)
            clipSlider.value = Float(currentTime)
        }
    }

    extension PlayerTableViewCell: AVAudioPlayerDelegate {

        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            updateViews()

        }

        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
            if let error = error {
                print("Audio Player Error: \(error)")
            }
            updateViews()
        }

}
