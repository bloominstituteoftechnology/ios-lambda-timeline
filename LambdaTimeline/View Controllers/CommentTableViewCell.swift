//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Daniela Parra on 11/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CommentTableViewCell: UITableViewCell, AVAudioPlayerDelegate {

    @IBAction func playAudio(_ sender: Any) {
        guard let audioData = audioData else { return }
        
        defer { updateViews() }
        
        guard !isPlaying else {
            player?.pause()
            return
        }
        
        if  player != nil && !isPlaying {
            player?.play()
            return
        }
        
        do {
            player = try AVAudioPlayer(data: audioData)
            player?.delegate = self
            player?.play()
        } catch {
            NSLog("Unable to play audio: \(error)")
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        updateViews()
    }
    
    // MARK: - Private Methods
    
    private func updateViews() {
        
        guard let comment = comment else { return }
        
        authorLabel.text = comment.author.displayName
        
        if comment.audioURL != nil {
            commentLabel.isHidden = true
            let imageString = isPlaying ? "pause" : "play"
            let image = UIImage(named: imageString)!
            audioButton.setImage(image, for: .normal)
            
        } else {
            audioButton.isHidden = true
            commentLabel.text = comment.text
        }
    }
    
    var comment: Comment? {
        didSet{
            updateViews()
        }
    }
    var audioData: Data?
   
    private var player: AVAudioPlayer?
    private var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var audioButton: UIButton!
    
}
