//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Bobby Keffury on 1/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CommentTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    var isPlaying: Bool = false
    var recordingURL: URL?
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            updateViews()
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    //MARK: - Views

    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateViews()
    }

    //MARK: - Methods
    
    private func updateViews() {
        playButton.isSelected = isPlaying
        
        if recordingURL != nil {
            playButton.isEnabled = true
        } else {
            playButton.isEnabled = false
        }
    }
    
    func play() {
        audioPlayer?.play()
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
    }
    
    //MARK: - Actions
    
    @IBAction func playButtonTapped(_ sender: Any) {
        isPlaying = !isPlaying
        updateViews()
        
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension CommentTableViewCell: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}
