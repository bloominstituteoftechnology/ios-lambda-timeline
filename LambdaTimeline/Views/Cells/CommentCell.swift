//
//  CommentCell.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var audioPlayerStackView: UIStackView!
    
    var manager = AudioManager()
    static let reuseID = "CommentCell"
    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    
    private func updateViews() {
        guard let comment = comment else { return }
        if let audio = comment.audio {
            print(audio)
        } else {
            timeElapsedLabel.removeFromSuperview()
            timeRemainingLabel.removeFromSuperview()
            valueSlider.removeFromSuperview()
            audioPlayerStackView.removeFromSuperview()
        }
    }
}

extension CommentCell: AudioManagerDelegate {
    func isRecording() {
        return
    }
    
    func doneRecording(with url: URL) {
        return
    }
}
