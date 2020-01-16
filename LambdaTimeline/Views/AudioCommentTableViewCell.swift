//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Jerry haaser on 1/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!
    
    var comment: Comment? {
        didSet {
            updateViews()
            loadAudio()
        }
    }
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    var data: Data?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        playPause()
    }
    
    func loadAudio() {
        let possibleSongURL = comment.audioURL
        
        guard let data = data else { return }
        
        audioPlayer = try! AVAudioPlayer(data: data)
        
        audioPlayer?.delegate = self
    }
    
    func play() {
        audioPlayer?.play()
        
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
        
        updateViews()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func updateViews() {
        authorLabel.text = comment?.author.displayName
        //print(comment.audioURL)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension AudioCommentTableViewCell: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio playback error: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
}
