//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var player: Player!
    var audioURLString: String? {
        didSet {
            setupPlayer()
        }
    }

    
    
    private func setupPlayer() {
        player = Player()
        
        
        //try! player.load(url: url)
        player.delegate = self
    }
    
    func setupAudio(data: Data) {
        do {
            try player.load(data: data)
        } catch {
            print("Error init player: \(error)")
        }
        
    }
    
    
    
    private func updateViews() {
        let title = player.isPlaying ? "Pause" : "Play"
        playButton.setTitle(title, for: .normal)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        player.playPause()
    }
    
}
extension AudioCommentTableViewCell: PlayerDelegate {
    func playerStateDidChange() {
        updateViews()
    }
    
    
}
