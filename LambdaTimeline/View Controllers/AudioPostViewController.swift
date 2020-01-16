//
//  AudioPostViewController.swift
//  LambdaTimeline
//
//  Created by Jerry haaser on 1/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPostViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    var postController: PostController?
    var post: Post?
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        
        return formatting
    }()
    
    var audioRecorder: AVAudioRecorder?
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    var recordURL: URL?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func record() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        let file = documentDirectory.appendingPathComponent(name).appendingPathComponent("caf")
        print("record URL: \(file)")
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        audioRecorder = try! AVAudioRecorder(url: file, format: format)
        recordURL = file
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
    }
    
    func updateViews() {
        let recordButtonTitle = isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
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
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        recordToggle()
    }
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
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
        if let recordURL = recordURL,
            var post = post {
            postController?.addComment(with: nil, audioURL: recordURL, to: &post)
            
            dismiss(animated: true, completion: nil)
        }
        updateViews()
    }
}
