//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Morgan Smith on 9/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var commentText: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else {
                return
            }
            audioPlayer.delegate = self
            togglePlaying()
        }
    }
    
    func updateViews() {
        guard let comment = comment else { return }
        if comment.text != "Audio Comment" {
            playButton.adjustsImageWhenDisabled = true
            playButton.backgroundImage(for: .disabled)
            commentText.text = comment.text
            authorLabel.text = comment.author.displayName
            
        } else {
            playButton.backgroundImage(for: .normal)
            loadAudio()
            togglePlaying()
            commentText.text = "Audio Comment"
            authorLabel.text = comment.author.displayName
        }
    }
    
    func togglePlaying() {
        playButton.isSelected = isPlaying
    }
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func loadAudio() {
         guard let comment = comment else { return }
        if comment.audio?.absoluteString == "No Audio", comment.audio == nil {
            return
        } else {
            guard let songURL = comment.audio else { return }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: songURL)
            } catch {
                preconditionFailure("Failure to load audio file: \(error)")
            }
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
            togglePlaying()
        } catch {
            print("Cannot play audio: \(error)")
        }
        
        
    }
    
    func pause() {
        audioPlayer?.pause()
        togglePlaying()
    }
    
    @IBAction func togglePlayback(_ sender: UIButton) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    
    
}

extension CommentTableViewCell: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        togglePlaying()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}

