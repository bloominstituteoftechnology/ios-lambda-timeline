//
//  AudioCommentView.swift
//  AudioComments
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

protocol AudioCommentViewDelegate {
    func startRecording(for audioCommentView: AudioCommentView)
    func stopRecording(for audioCommentView: AudioCommentView)
    func startPlayback(for audioCommentView: AudioCommentView)
    func pausePlayback(for audioCommentView: AudioCommentView)
    func scrubPlayback(to location: Float, for audioCommentView: AudioCommentView)
    
    func sendAudioComment(for audioCommentView: AudioCommentView)
    func sendTextualComment(with text: String, for audioCommentView: AudioCommentView)
}

class AudioCommentView: UIView {
    
    /// The configuration of the AudioCommentView's subviews depends on the state it is in.
    /// It starts in emptyText mode, and transitions to someText when typing begins in the text field.
    /// If instead of typing, the user taps the record button, it transitions to recording mode.
    /// Finally, after completion of recording, it transitions to playback mode.
    enum UIMode {
        case emptyText
        case someText
        case recording
        case playback
    }
    
    // MARK: - Private Properties
    
    private(set) var uiMode = UIMode.emptyText {
        didSet {
            if oldValue != uiMode {
                updateUI()
            }
        }
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
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK: - Private Methods
    
    private func setup() {
        Bundle.main.loadNibNamed("AudioCommentView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textField.delegate = self
        textField.autocorrectionType = .no
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
    }
    
    // MARK: - IBActions
     
     @IBAction func toggleRecording(_ sender: UIButton) {
         recordButton.isSelected.toggle()
         self.uiMode = recordButton.isSelected ? .recording : .playback
     }
     
     @IBAction func cancel(_ sender: Any) {
         self.uiMode = .emptyText
     }
     
     @IBAction func send(_ sender: Any) {
         print("Sending the comment")
     }
}

extension AudioCommentView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.uiMode = textField.text == "" ? .emptyText : .someText
    }
}

extension UIView {
    
    static func hide(_ views: UIView...) {
        for view in views {
            view.isHidden = true
        }
    }
    
    static func show(_ views: UIView...) {
        for view in views {
            view.isHidden = false
        }
    }
}
