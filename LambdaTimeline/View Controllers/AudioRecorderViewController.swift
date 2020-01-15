//
//  AudioRecorderViewController.swift
//  LambdaTimeline
//
//  Created by Jordan Christensen on 10/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioRecorderViewController: UIViewController {
    
    var recorder = Recorder()
    var player: Player?

    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        player?.delegate = self
        recorder.delegate = self
    }
    
    func updateViews() {
        let playTitle = player?.isPlaying ?? false ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: playTitle), for: .normal)
        
        let recordTitle = recorder.isRecording ? "stop.fill" : "recordingtape"
        recordButton.setImage(UIImage(systemName: recordTitle), for: .normal)
        
        currentTimeLabel.text = timeFormatter.string(from: player?.timeElapsed ?? 0.0)
        durationLabel.text = timeFormatter.string(for: player?.timeRemaining)
        
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(player?.duration ?? 0.0)
        timeSlider.value = Float(player?.timeElapsed ?? 0.0)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        player?.playPause()
        updateViews()
    }
    
    @IBAction func recordStopTapped(_ sender: UIButton) {
        recorder.toggleRecording()
        updateViews()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AudioRecorderViewController: PlayerDelegate {
    func playerDidChangeState(_ player: Player) {
        updateViews()
    }
}

extension AudioRecorderViewController: RecorderDelegate {
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    
    func recorderDidSaveFile(_ recorder: Recorder) {
        updateViews()
        //TODO: play the file
        if let url = recorder.url, !recorder.isRecording {
            player = Player(url: url)
            player?.delegate = self
        }
    }
}
