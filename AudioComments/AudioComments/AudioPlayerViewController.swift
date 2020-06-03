//
//  AudioPlayerViewController.swift
//  AudioComments
//
//  Created by Bhawnish Kumar on 6/2/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit
import AVFoundation
class AudioPlayerViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self
        }
    }
    var timer: Timer?
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var audioSlider: UISlider!
    @IBOutlet private var recordingButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
          // NOTE: DateComponentFormatter is good for minutes/hours/seconds
          // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
          
          let formatting = DateComponentsFormatter()
          formatting.unitsStyle = .positional // 00:00  mm:ss
          formatting.zeroFormattingBehavior = .pad
          formatting.allowedUnits = [.minute, .second]
          return formatting
      }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        cancelTimer()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
    }
    
    @IBAction func togglePlayback(_ sender: Any) {
        
    }
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        
    }
    
    func startTimer() {
    timer?.invalidate() // import to invalidate the timer to start a new one to prevent multiple timers.
    timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
        guard let self = self else { return }
        self.updateViews()
        }
    }
    
    func cancelTimer() {
           timer?.invalidate()
           timer = nil
       }
        
    func updateViews() {
        playButton.isSelected = isPlaying
        
        let elapsedTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0
        
        let timeRemaining = round(duration) - elapsedTime
        currentTime.text = timeIntervalFormatter.string(from: elapsedTime)
        durationTime.text = timeIntervalFormatter.string(from: timeRemaining)
    }
    
    func play() {
        audioPlayer?.play()
        startTimer()
        updateViews()
    }
        
        func pause() {
        audioPlayer?.pause()
            cancelTimer()
            updateViews()
        }
        
    func togglePlayBack() {
        if isPlaying {
            pause()
        } else {
            play()
        }
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

extension AudioPlayerViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print(error)
        }
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
}
