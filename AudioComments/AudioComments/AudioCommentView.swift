//
//  AudioCommentView.swift
//  AudioComments
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class AudioCommentView: UIView {
    
    enum UIMode {
        case emptyText
        case someText
        case recording
        case playback
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timelineSlider: UISlider!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    @IBOutlet weak var textField: UITextField!
    
    
    // MARK: - Private Properties
    
    var uiMode = UIMode.emptyText {
        didSet {
            if oldValue != uiMode {
                updateUI()
            }
        }
    }
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @IBAction func toggleRecording(_ sender: UIButton) {
        recordButton.isSelected.toggle()
        self.uiMode = recordButton.isSelected ? .recording : .emptyText
    }
    
    //MARK: - Private Methods
    
    private func setup() {
        Bundle.main.loadNibNamed("AudioCommentView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
    }

    private func updateUI() {
        switch uiMode {
        case .emptyText:
            print("emptyText")
            UIView.hide(playPauseButton, sendButton, clearButton, timelineSlider, audioVisualizer)
            UIView.show(textField, recordButton)
        case .someText:
            print("someText")
            UIView.hide(playPauseButton, sendButton, clearButton, timelineSlider, audioVisualizer, recordButton)
            UIView.show(textField, sendButton)
        case .recording:
            print("recording")
            UIView.hide(playPauseButton, sendButton, clearButton, timelineSlider, textField)
            UIView.show(audioVisualizer, recordButton)
        case .playback:
            print("playback")
            UIView.hide(textField, audioVisualizer, recordButton)
            UIView.show(playPauseButton, timelineSlider, clearButton, sendButton)
        }
        
        UIView.animate(withDuration: 2) {
            self.layoutIfNeeded()
        }
    }
    
}

extension UIView {
    
    static func hide(_ views: UIView...) {
        for view in views {
            UIView.animate(withDuration: 0.3, animations: {
                view.layer.opacity = 0
            }) { _ in
                view.isHidden = true
            }
        }
    }
    
    static func show(_ views: UIView...) {
        for view in views {
            view.layer.opacity = 0
            view.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                view.layer.opacity = 1
            }
        }
    }
}
