//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    let recorder = Recorder()
    var postController: PostController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recorder.delegate = self
        
        sendButton.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        recorder.toggleRecord()
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        recorder.cancelRecord()
    }
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        
    }
    
    private func updateViews() {
        let title = recorder.isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(title, for: .normal)
    }
    
}

extension AudioCommentViewController: RecorderDelegate {
    func recorderDidChangeState() {
        updateViews()
    }
    
    func recorderDidFinishSavingFile(_ recorder: Recorder, url: URL) {
        sendButton.isHidden = false
    }
    
    
}
