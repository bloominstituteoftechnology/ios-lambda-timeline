//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Ciara Beitel on 10/29/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentViewController: UIViewController {
    
    var player: Player
    var recorder: Recorder
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!

    private lazy var timeFormatter: DateComponentsFormatter = {
            let formatting = DateComponentsFormatter()
            formatting.unitsStyle = .positional
            formatting.zeroFormattingBehavior = .pad
            formatting.allowedUnits = [.minute, .second]
            return formatting
    }()
        
    required init?(coder: NSCoder) {
        self.recorder = Recorder()
        self.player = Player()
        super.init(coder: coder)
        player.delegate = self
        recorder.delegate = self
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize, weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize, weight: .regular)
        updateViews()
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        player.playPause()
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        recorder.toggleRecording()
    }
    
    private func updateViews() {
        let playTitle = player.isPlaying ? "Pause" : "Play"
        playButton.setTitle(playTitle, for: .normal)
        let recordTitle = recorder.isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(recordTitle, for: .normal)
        timeLabel.text = timeFormatter.string(from: player.timeElapsed)
        timeRemainingLabel.text = timeFormatter.string(from: player.timeRemaining)
        durationSlider.minimumValue = 0
        durationSlider.maximumValue = Float(player.duration)
        durationSlider.value = Float(player.timeElapsed)
    }
}

extension AudioCommentViewController: PlayerDelegate {
    func playerDidChangeState(player: Player) {
        updateViews()
    }
}

extension AudioCommentViewController: RecorderDelegate {
    func recorderDidChangeState(recorder: Recorder) {
        updateViews()
    }
    
    func recorderDidSaveFile(recorder: Recorder) {
        updateViews()
        if let url = recorder.url, recorder.isRecording == false {
            player = Player(url: url)
            player.delegate = self
        }
    }
}
