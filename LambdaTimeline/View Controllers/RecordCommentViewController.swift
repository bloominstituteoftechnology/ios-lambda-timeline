//
//  RecordCommentViewController.swift
//  LambdaTimeline
//
//  Created by Christopher Aronson on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordCommentViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    
    var recorder: AVAudioRecorder?
    var postController: PostController?
    var post: Post?
    
    var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func newRecordingURL() -> URL {
        
        let fm = FileManager.default
        let documentDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    @IBAction func record(_ sender: Any) {

        if isRecording {
            recordButton.setTitle("Record", for: .normal)
            recorder?.stop()
        } else {
            
            do {
                let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
                recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
                recorder?.delegate = self
                recordButton.setTitle("Stop Recording", for: .normal)
                recorder?.record()
            } catch {
                NSLog("Unable to record")
            }
        }
    }
}

extension RecordCommentViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        do {
            let audioData = try Data(contentsOf: recorder.url)
            postController?.addAudioComment(with: audioData, to: post!)
        } catch {
            NSLog("Could not load audio file from url: \(error)")
        }
        
        self.recorder = nil
    }
    
}
