//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Ciara Beitel on 10/29/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentViewController: UIViewController {
    
    var recorder: Recorder
    
    private lazy var timeFormatter: DateComponentsFormatter = {
            let formatting = DateComponentsFormatter()
            formatting.unitsStyle = .positional
            formatting.zeroFormattingBehavior = .pad
            formatting.allowedUnits = [.minute, .second]
            return formatting
    }()
    
    @IBOutlet weak var recordButton: UIButton!
    
    required init?(coder: NSCoder) {
        self.recorder = Recorder()
        super.init(coder: coder)
        recorder.delegate = self
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        recorder.toggleRecording()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        cancelRecording()
    }
    
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        sendRecording()
    }
    
    private func updateViews() {
        let recordTitle = recorder.isRecording ? "Stop Recording" : "Record"
        recordButton.setTitle(recordTitle, for: .normal)
    }
    
    private func cancelRecording() {
        recorder.stop()
        dismiss(animated: true, completion: nil)
    }
    
    private func sendRecording() {
    }
}

extension AudioCommentViewController: RecorderDelegate {
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    
    func recorderDidFinishSavingFile(_ recorder: Recorder, url: URL) {
        if !recorder.isRecording {
            // send info to table view?
        }
    }
}
