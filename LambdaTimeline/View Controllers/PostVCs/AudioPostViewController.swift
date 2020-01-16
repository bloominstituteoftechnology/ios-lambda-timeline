//
//  AudioPostViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-14.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPostViewController: PostViewController {

    override var mediaData: Data? { audioRecordererControl.audioData }

    // MARK: - Outlets

    @IBOutlet var audioRecordererControl: AudioRecorderControl!
    @IBOutlet var audioPlayerControl: AudioPlayerControl!
    @IBOutlet var reRecordButton: UIButton!

    // MARK: - View Lifecycle / Update

    override func viewDidLoad() {
        super.viewDidLoad()
        audioRecordererControl.delegate = self
        updateViews()
    }

    private func updateViews() {
        let hasRecordedData = (mediaData != nil)
        title = post?.title ?? "New Post"
        audioRecordererControl.isHidden = hasRecordedData
        audioPlayerControl.isHidden = !hasRecordedData
        reRecordButton.isHidden = !hasRecordedData
    }

    // MARK: - Actions

    @IBAction func reRecordButtonTapped(_ sender: UIButton) {
        clearRecordedData()
    }

    // MARK: - Methods

    private func clearRecordedData() {
        updateViews()
    }

    private func setUpPlayer() {
        if let data = mediaData {
            audioPlayerControl.loadAudio(from: data)
        }
        updateViews()
    }

    override func createPost() {
        if let data = audioRecordererControl.audioData {
            createPost(ofType: .audio, with: data)
        } else {
            presentInformationalAlertController(
                title: "Uh-oh",
                message: "Make sure that you record something.")
        }
    }
}

// MARK: - AudioRecorderControlDelegate

extension AudioPostViewController: AudioRecorderControlDelegate {
    func audioRecorderControl(
        _ recorderControl: AudioRecorderControl,
        didFinishRecordingSucessfully didFinishRecording: Bool
    ) {
        setUpPlayer()
    }
}
