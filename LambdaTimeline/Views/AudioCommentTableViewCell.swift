//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Clayton Watkins on 9/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentTableViewCell: UITableViewCell {
    
    var recordingURL: URL?
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        print(recordingURL!)
        do {
            try prepareAudioSession()
            if let recordingURL = recordingURL{
                print(recordingURL)
                audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
                guard let audioPlayer = self.audioPlayer else { return }
                audioPlayer.play()
            }
            
        } catch {
            preconditionFailure("Failure to load audio file at path \(recordingURL!): \(error)")
        }
    }
}
