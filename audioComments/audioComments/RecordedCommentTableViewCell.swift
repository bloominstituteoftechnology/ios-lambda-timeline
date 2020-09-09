//
//  RecordedCommentTableViewCell.swift
//  audioComments
//
//  Created by Morgan Smith on 9/8/20.
//  Copyright © 2020 Morgan Smith. All rights reserved.
//

import UIKit
import AVFoundation

class RecordedCommentTableViewCell: UITableViewCell {

    override func awakeFromNib() {
         super.awakeFromNib()
     }

    var audioPlayer: AVAudioPlayer? {
           didSet {
               guard let audioPlayer = audioPlayer else {
                   return
               }
               audioPlayer.delegate = self
               updateViews()
           }
       }

    var recordingURL: URL? {
        didSet {
            loadAudio()
            updateViews()
        }
    }

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!



    func updateViews() {
          playButton.isSelected = isPlaying
      }




    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }



    func loadAudio() {
        guard let songURL = recordingURL else { return }

          do {
              audioPlayer = try AVAudioPlayer(contentsOf: songURL)
          } catch {
              preconditionFailure("Failure to load audio file: \(error)")
          }
      }

    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }

    func play() {
           do {
               try prepareAudioSession()
               audioPlayer?.play()
               updateViews()
           } catch {
               print("Cannot play audio: \(error)")
           }


       }

       func pause() {
           audioPlayer?.pause()
           updateViews()
       }

    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }


}


extension RecordedCommentTableViewCell: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}

