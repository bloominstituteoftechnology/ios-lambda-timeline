//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Luqmaan Khan on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentViewController: UIViewController {
    
       lazy private var audioPlayer = AudioPlayer()
       lazy private var recorder = Recorder()
       var postController: PostController!
       var post: Post!
    var recordingURL: URL?

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
     @IBOutlet var playButton: UIButton!
    
    private lazy var timeFormatter: DateComponentsFormatter = {
              let formatting = DateComponentsFormatter()
              formatting.unitsStyle = .positional // 00:00
              formatting.zeroFormattingBehavior = .pad
              formatting.allowedUnits = [.minute, .second]
              return formatting
          }()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize,weight: .regular)
               timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,weight: .regular)
               let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
               audioPlayer.delegate = self
               recorder.delegate = self
               updateSlider()
    }

    @IBAction func recordButtonTapped(_ sender: UIButton) {
         recorder.toggleRecording()
    }
    @IBAction func playButtonTapped(_ sender: UIButton) {
        audioPlayer.playPause()
        updateSlider()
    }
    @IBAction func createCommentButtonTapped(_ sender: UIButton) {
        
        guard let recording = recordingURL else {return}
        self.postController.addAudioComment(with: recording, to: &self.post!)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSlider() {
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(audioPlayer.duration)
        timeSlider.value = Float(audioPlayer.elapsedTIme)
    }
    
    func updateViews() {
        let playButtonTitle = audioPlayer.isPlaying ? "Pause" : "Play"
        playButton.setTitle(playButtonTitle, for: .normal)
        let recordButtonTitle = recorder.isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
        timeLabel.text = timeFormatter.string(from: audioPlayer.elapsedTIme)
        timeRemainingLabel.text = timeFormatter.string(from: audioPlayer.timeRemaining)
        updateSlider()
    }
}
extension AudioCommentViewController: AudioPlayerDelegate {
    func playerDidChangeState(player: AudioPlayer) {
        updateViews()
    }
}
extension AudioCommentViewController: RecorderDelegate {
    func recorderDidChangeState(recorder: Recorder) {
        updateViews()
    }
    func recorderDidFinishSavingFile(recorder: Recorder, url: URL) {
        if !recorder.isRecording {
           try!  audioPlayer.load(url: url)
            recordingURL = url
        }
    }
}
