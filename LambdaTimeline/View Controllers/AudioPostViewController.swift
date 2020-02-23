//
//  AudioPostViewController.swift
//  LambdaTimeline
//
//  Created by morse on 1/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPostViewController: UIViewController {
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    
    
    // MARK: - Properties
    
    var postController: PostController?
    var post: Post?
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        // NOTE: DateComponentsFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter not good for milliseconds, use DateFormatter instead)
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    var audioRecorder: AVAudioRecorder?
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    var recordURL: URL?
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Methods
    
    func record() {
        // Path to save in the Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // Filename (ISO8601 format for time) .caf
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        // 2020-1-14.caf
        let file = documentsDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        
        print("record URL: \(file)")
        
        // 44.1 Khz is CD quality audio
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        // Start a recording
        audioRecorder = try! AVAudioRecorder(url: file, format: format) // FIXME: error handling
        recordURL = file
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
    }
    
    func recordToggle() {
        if isRecording {
            stopRecording()
        } else {
            record()
        }
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        recordToggle()
    }
    
    private func updateViews() {
//        let playButtonTitle = isPlaying ? "Pause" : "Play"
//        playButton.setTitle(playButtonTitle, for: .normal)
//
//        let elapsedTime = audioPlayer?.currentTime ?? 0
//        timeLabel.text = timeFormatter.string(from: elapsedTime)
//
//        let duration = audioPlayer?.duration ?? 0
//        let timeRemaining = duration - elapsedTime
//        timeRemainingLabel.text = timeFormatter.string(from: timeRemaining)
//
//        timeSlider.minimumValue = 0
//        timeSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
//        timeSlider.value = Float(elapsedTime)
        
        let recordButtonTitle = isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
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

extension AudioPostViewController: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Record error: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // TODO: Create player with new file URL
        
        // TODO: create note
        
        if let recordURL = recordURL,
            var post = post {
            
            postController?.addComment(with: nil, audioURL: recordURL, to: &post)
            
            dismiss(animated: true, completion: nil)
        }
        
        updateViews()
//        if let recordURL = recordURL {
//            audioPlayer = try! AVAudioPlayer(contentsOf: recordURL) // FIXME: make safer
//            updateViews()
//        }
    }
}
