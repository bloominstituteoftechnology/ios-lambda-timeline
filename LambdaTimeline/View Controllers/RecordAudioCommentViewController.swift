//
//  RecordAudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Daniela Parra on 11/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioCommentsUpdateDelegate {
    func audioCommentsDidUpdate()
}

class RecordAudioCommentViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBAction func record(_ sender: Any) {
        defer { updateButtons() }
        
        guard !isRecording else {
            recorder?.pause()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Error starting recording: \(error)")
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        
        guard isRecording else { return }
        recorder?.stop()
        recordingURL = recorder?.url
        self.recorder = nil
        updateButtons()
    }
    
    @IBAction func sendAudioComment(_ sender: Any) {
        guard let recordingURL = recordingURL,
            let post = post else { return }
        
        postController?.addAudioComment(with: recordingURL, to: post)
        delegate?.audioCommentsDidUpdate()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingURL = recorder.url
        self.recorder = nil
        updateButtons()
    }
    
    private func newRecordingURL() -> URL {
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        //Any path component could be a file name
        return documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    private func updateButtons() {
        let imageString = isRecording ? "pause" : "record"
        let image = UIImage(named: imageString)!
        recordButton.setImage(image, for: .normal)
    }
    
    // MARK: - Properties
    
    private var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?
    var post: Post?
    var postController: PostController?
    var delegate: AudioCommentsUpdateDelegate?

    @IBOutlet weak var recordButton: UIButton!
}
