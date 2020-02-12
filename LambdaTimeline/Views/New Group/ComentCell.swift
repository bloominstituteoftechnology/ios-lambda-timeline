//
//  ComentCell.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ComentCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemaningLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var audioPlayerStackView: UIStackView!
    
    var manager = AudioManager()
    static let reuseID = "ComentCell"
    
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
            timeRemaningLabel.removeFromSuperview()
            valueSlider.removeFromSuperview()
            audioPlayerStackView.removeFromSuperview()
        }
    }
}

extension ComentCell: AudioManagerDelegate {
    func isRecording() {
        return
    }
    
    func doneRecording(with url: URL) {
        return
    }
    
    
}
