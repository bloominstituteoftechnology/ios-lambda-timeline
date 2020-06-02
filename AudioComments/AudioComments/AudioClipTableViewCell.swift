//
//  AudioClipTableViewCell.swift
//  AudioComments
//
//  Created by Chris Dobek on 6/2/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import AVFoundation

class AudioClipTableViewCell: UITableViewCell {

   // MARK: - Properites
       var clip: URL!

       var audioPlayer: AVAudioPlayer? {
           didSet {
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
           audioPlayer = try? AVAudioPlayer(contentsOf: clip)
       }

       func prepareAudioSession() throws {
           let session = AVAudioSession.sharedInstance()
           try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
           try session.setActive(true, options: []) // can fail if on a phone call, for instance
       }

       private func play() {
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

       private func pause() {
           audioPlayer?.pause()
           cancelTimer()
           updateViews()
       }

       // MARK: - Actions

       @IBAction func togglePlayButton(_ sender: UIButton) {
           if isPlaying {
               pause()
           } else {
               play()
           }
       }

       @IBAction func togglePlayback(_ sender: UISlider) {
           if isPlaying {
               pause()
           }

           audioPlayer?.currentTime = TimeInterval(clipSlider.value)
           updateViews()
       }

       // MARK: - Outlets
       @IBOutlet weak var playButton: UIButton!
       @IBOutlet weak var clipSlider: UISlider!

       // MARK: - Timer

       var timer: Timer?

       func startTimer() {
           timer?.invalidate() // Start with a new timer!

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
           playButton.isSelected = isPlaying

           let currentTime = audioPlayer?.currentTime ?? 0.0
           let duration = audioPlayer?.duration ?? 0.0

           clipSlider.minimumValue = 0
           clipSlider.maximumValue = Float(duration)
           clipSlider.value = Float(currentTime)
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