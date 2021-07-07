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
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute,.second]
        return formatter
    }()
    
    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize, weight: .regular)
        timeRemaningLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemaningLabel.font.pointSize, weight: .regular)
        
        
        guard let comment = comment else { return }
        if let audio = comment.audio {
            guard let audioURL = URL(string: audio) else { return }
            manager.loadAudio(with: audioURL)
            manager.delegate = self
            updateAudioControlls(withComment: true)
            
            
        } else {
            timeElapsedLabel.removeFromSuperview()
            timeRemaningLabel.removeFromSuperview()
            valueSlider.removeFromSuperview()
            audioPlayerStackView.removeFromSuperview()
        }
        
        titleLabel.text = comment.text
        authorLabel.text = comment.author.displayName
    }
    
    
    private func updateAudioControlls(withComment: Bool) {
        if withComment {
            let elapsedTime = manager.audioPlayer?.currentTime ?? 0
            timeElapsedLabel.text = timeIntervalFormatter.string(for: elapsedTime)
            
            valueSlider.minimumValue = 0
            valueSlider.maximumValue = Float(manager.audioPlayer?.duration ?? 0)
            valueSlider.value = Float(elapsedTime)
            
            let timeRemaining = (manager.audioPlayer?.duration ?? 0) - elapsedTime
            timeRemaningLabel.text = timeIntervalFormatter.string(from: timeRemaining)
        }
    }
    
}

extension ComentCell: AudioManagerDelegate {
    func didUpdate() {
       updateAudioControlls(withComment: true)
    }
    
    func didPlay() {
        updateAudioControlls(withComment: true)
    }
    
    func didPause() {
        updateAudioControlls(withComment: true)
    }
    
    func didFinishPlaying() {
        updateAudioControlls(withComment: true)
    }
    
    func isRecording() {
        return
    }
    
    func doneRecording(with url: URL) {
        return
    }
    
    
}
