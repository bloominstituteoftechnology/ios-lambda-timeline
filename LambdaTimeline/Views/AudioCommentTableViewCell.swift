//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Wyatt Harrell on 5/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol PlayCommentAudioDelegate: AnyObject {
    func playAudio(for url: URL)
}

class AudioCommentTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var delegate: PlayCommentAudioDelegate?
    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let comment = comment else { return }
        authorLabel?.text = comment.author.displayName

    }

    @IBAction func playButtonTapped(_ sender: Any) {
        guard let comment = comment, let url = comment.audioURL else { return }
        delegate?.playAudio(for: url)
    }
}
