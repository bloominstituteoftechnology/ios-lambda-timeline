//
//  ViewController.swift
//  AudioPrototype
//
//  Created by Kenny on 6/2/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderViewController: UIViewController {
    // MARK: - Outlets -
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    var recorderURL: URL?

    // MARK: - Properties -
    //lazy to ensure self is available
    lazy var audioRecorder = RecordingController(delegate: self)

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(
            ofSize: timeElapsedLabel.font.pointSize,
            weight: .regular
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        try? audioRecorder.prepareAudioSession()
    }

    private func updateViews() {
        recordButton.isSelected = audioRecorder.isRecording
        displayElapsedTime()
    }

    private func displayElapsedTime() {
        let elapsedTime = audioRecorder.recorder?.currentTime ?? 0
        timeElapsedLabel.text = audioRecorder.timeIntervalFormatter.string(from: elapsedTime)
    }


    // MARK: - Actions
    @IBAction func toggleRecording(_ sender: Any) {
        audioRecorder.toggleRecording()
    }

//    // MARK: - Navigation -
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let destination = segue.destination as? AudioCommentTableViewController else { return }
//        destination.recordedURL = recorderURL
//    }
}

extension AudioRecorderViewController: RecordingUIDelegate {
    func updateUI() {
        updateViews()
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = audioRecorder.recordingURL {
            self.recorderURL = recordingURL
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Error recording: \(error)")
        }
    }
}
