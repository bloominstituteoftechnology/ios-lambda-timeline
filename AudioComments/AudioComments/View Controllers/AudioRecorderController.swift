//
//  AudioRecorderController.swift
//  AudioComments
//
//  Created by David Wright on 5/10/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderController: UIViewController {
    
    private var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            updateViews()
        }
    }
    
    private var recordingURL: URL?
    private var audioRecorder: AVAudioRecorder?
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    // MARK: - IBOutlets
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                                 weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
    }
    
    // MARK: - IBActions
    
    @IBAction func togglePlayback(_ sender: UIButton) {
        // TODO: Implement togglePlayback
        
    }
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        // TODO: Implement updateCurrentTime
        
    }
    
    @IBAction func toggleRecording(_ sender: UIButton) {
        // TODO: Implement toggleRecording
        
    }
    
    // MARK: - Update Views
    
    private func updateViews() {
        // TODO: Implement updateViews
    }
    
    // MARK: - Timer
    
    private weak var timer: Timer?
    
    func startTimer() {
        // TODO: Implement startTimer
        
    }
    
    func cancelTimer() {
        // TODO: Implement cancelTimer
        
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Playback
    
    private var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    private func prepareAudioSession() throws {
        // TODO: Implement prepareAudioSession
        
    }
    
    private func play() {
        // TODO: Implement play
        
    }
    
    private func pause() {
        // TODO: Implement pause
        
    }
    
    // MARK: - Recording
    
    private var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    func createNewRecordingURL() -> URL {
        // TODO: Implement pause
        
        return URL(fileURLWithPath: "") // placeholder return value
    }
    
    func requestPermissionOrStartRecording() {
        // TODO: Implement requestPermissionOrStartRecording
        
    }
    
    func startRecording() {
        // TODO: Implement startRecording
        
    }
    
    func stopRecording() {
        // TODO: Implement stopRecording
        
    }
    
}


// MARK: - AVAudioPlayerDelegate

extension AudioRecorderController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // TODO: Implement audioPlayerDidFinishPlaying
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        // TODO: Implement audioPlayerDecodeErrorDidOccur
        
    }
}


// MARK: - AVAudioRecorderDelegate

extension AudioRecorderController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // TODO: Implement audioRecorderDidFinishRecording
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        // TODO: Implement audioRecorderEncodeErrorDidOccur
        
    }
}
