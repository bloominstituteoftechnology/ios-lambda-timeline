//
//  AudioCommentView.swift
//  AudioComments
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

protocol AudioCommentViewDelegate: AnyObject {
    func sendAudioComment(with url: URL)
    func sendTextualComment(with text: String)
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
    
    // MARK: - Public Properties
    
    weak var delegate: AudioCommentViewDelegate?
    let audioRecorder = AudioRecorder()
    
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
    
    // MARK: - Private Methods
    
    private func setup() {
        Bundle.main.loadNibNamed("AudioCommentView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textField.delegate = self
        textField.autocorrectionType = .no
        
        audioRecorder.delegate = self
    }
    
    private func updateUI() {
        switch uiMode {
        case .emptyText:
            print("emptyText mode")
            UIView.hide(playPauseButton, sendButton, clearButton, timelineSlider, audioVisualizer)
            UIView.show(textField, recordButton)
        case .someText:
            print("someText mode")
            UIView.hide(playPauseButton, sendButton, clearButton, timelineSlider, audioVisualizer, recordButton)
            UIView.show(textField, sendButton)
        case .recording:
            print("recording mode")
            UIView.hide(playPauseButton, sendButton, clearButton, timelineSlider, textField)
            UIView.show(audioVisualizer, recordButton)
        case .playback:
            print("playback mode")
            UIView.hide(textField, audioVisualizer, recordButton)
            UIView.show(playPauseButton, timelineSlider, clearButton, sendButton)
        }
    }
    
    private func sendTextualComment() {
        guard let text = textField.text else { return }
        
        delegate?.sendTextualComment(with: text)
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    private func sendAudioComment() {
        guard let url = audioRecorder.fileURL else { return }

        delegate?.sendAudioComment(with: url)
        uiMode = .emptyText
        textField.resignFirstResponder()
    }
    
    private func startRecording() {
        audioRecorder.startRecording()
        recordButton.isSelected = true
        uiMode = .recording
    }
    
    private func stopRecording() {
        audioRecorder.stopRecording()
    }
    
    private func play() {
        audioRecorder.play()
        playPauseButton.isSelected = true
    }
    
    private func pause() {
        audioRecorder.pause()
        playPauseButton.isSelected = false
    }

    // MARK: - IBActions
    
    @IBAction func togglePlayback(_ sender: UIButton) {
        if audioRecorder.isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func toggleRecording(_ sender: UIButton) {
        if audioRecorder.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.uiMode = .emptyText
        audioRecorder.pause()
    }
    
    @IBAction func send(_ sender: UIButton) {
        if uiMode == .playback {
            sendAudioComment()
        } else if uiMode == .someText {
            sendTextualComment()
        }
    }
    
    @IBAction func scrubTimeline(_ sender: UISlider) {
        audioRecorder.scrub(to: TimeInterval(sender.value))
        playPauseButton.isSelected = false
    }
}

extension AudioCommentView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.uiMode = textField.text == "" ? .emptyText : .someText
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text != "" else { return false }
        sendTextualComment()
        return true
    }
}

extension AudioCommentView: AudioRecorderDelegate {
    func didUpdatePlaybackLocation(to time: TimeInterval) {
        timelineSlider.value = Float(time)
    }
    
    func didFinishPlaying() {
        playPauseButton.isSelected = false
    }
    
    func didUpdateAudioAmplitude(to decibels: Float) {
        audioVisualizer.addValue(decibelValue: decibels)
        print(decibels)
    }
    
    func didRecord(to fileURL: URL, with duration: TimeInterval) {
        recordButton.isSelected = false
        timelineSlider.maximumValue = Float(duration)
        timelineSlider.value = 0
        playPauseButton.isSelected = false
        uiMode = .playback
    }
}
