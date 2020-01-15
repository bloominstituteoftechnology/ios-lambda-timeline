//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by morse on 1/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!
    
    // MARK: - Properties
    
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
    
    // MARK: - Actions
    
    @IBAction func playTapped(_ sender: Any) {

        print("tapped")
        playPause()
        
    }
    
    func loadAudio() {
        // piano.mp3
        
        // Will crach, good for finding bugs early during development, but
        // risky if you're shipping an app to the App Store (1 star review)
        let possibleSongURL = comment?.audioURL
        
        guard let data = data else { return }
        
        // create the player
        audioPlayer = try! AVAudioPlayer(data: data) // RISKY: will crash if not there, do, try, catch would be better
        audioPlayer?.delegate = self
    }
    
    func play() {
        audioPlayer?.play()
//        startTimer()
        
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
//        cancelTimer()
        updateViews()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
//    private func startTimer() {
//        cancelTimer()
//        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
//    }
//
//    @objc private func updateTimer(timer: Timer) {
//        updateViews()
//    }
//
//    private func cancelTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        loadAudio()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        
        authorLabel.text = comment?.author.displayName
        print(comment?.audioURL)
    }
    
    

}

// MARK: - Extensions

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
