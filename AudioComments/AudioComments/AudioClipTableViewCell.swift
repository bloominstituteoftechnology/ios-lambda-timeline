//
//  AudioClipTableViewCell.swift
//  AudioComments
//
//  Created by Mark Gerrior on 5/5/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
//

import UIKit
import AVFoundation

class AudioClipTableViewCell: UITableViewCell {

    // MARK: - Properites
    var clip: URL!

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
    
    func loadAudio(_ clip: URL) {
        // DRM will fail this call
        audioPlayer = try? AVAudioPlayer(contentsOf: clip)
    }

    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }

    // MARK: - Actions

    @IBAction func clipSlider(_ sender: UISlider) {
    }

    @IBAction func playPauseButton(_ sender: UIButton) {
        if audioPlayer == nil {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: clip)
            } catch {
                print("Couldn't load clip; we tried: \(clip.absoluteString)")
                return
            }
        }
        audioPlayer?.play()
        startTimer()
        updateViews()
    }

    // MARK: - Outlets
    @IBOutlet weak var playPauseButtonOutlet: UIButton!

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

    }
}

extension AudioClipTableViewCell: AVAudioPlayerDelegate {

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
