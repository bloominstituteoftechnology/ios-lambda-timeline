//
//  RecordingTableViewCell.swift
//  LambdaTimeline
//
//  Created by Moses Robinson on 3/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol RecordingTableViewCellDelegate: class {
    func playAudio(for cell: RecordingTableViewCell)
}

class RecordingTableViewCell: UITableViewCell {
    
    @IBAction func playButtonPressed(_ sender: Any) {
        delegate?.playAudio(for: self)
    }
    

    private func updateViews() {
        
        guard let comment = comment else { return }
        
        authorLabel.text = comment.author.displayName
        
        let playButtonTitle = isPlaying ? "Stop" : "Play"
        playButton.setTitle(playButtonTitle, for: .normal)
    }
    
    // MARK: - Properties
    
    var player: AVAudioPlayer?
    
    var delegate: RecordingTableViewCellDelegate?
    
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }

    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var playButton: UIButton!
}
