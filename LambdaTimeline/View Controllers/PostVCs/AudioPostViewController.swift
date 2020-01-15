//
//  AudioPostViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-14.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPostViewController: ShiftableViewController {

    // MARK: - Properties

    var postController: PostController!
    var post: Post?

    var audioData: Data? {
        didSet { setUpPlayer() }
    }

    // MARK: - Outlets

    @IBOutlet var audioRecordererControl: AudioRecorderControl!
    @IBOutlet var audioPlayerControl: AudioPlayerControl!
    @IBOutlet var reRecordButton: UIButton!
    @IBOutlet var titleTextField: UITextField!

    // MARK: - View Lifecycle / Update

    override func viewDidLoad() {
        super.viewDidLoad()
        audioRecordererControl.delegate = self
        updateViews()
    }

    private func updateViews() {
        let hasRecordedData = (audioData != nil)
        title = post?.title ?? "New Post"
        audioRecordererControl.isHidden = hasRecordedData
        audioPlayerControl.isHidden = !hasRecordedData
        reRecordButton.isHidden = !hasRecordedData
    }

    // MARK: - Actions

    @IBAction func reRecordButtonTapped(_ sender: UIButton) {
        clearRecordedData()
    }

    @IBAction func createPostButtonTapped(_ sender: Any) {
        createPost()
    }

    // MARK: - Methods

    private func clearRecordedData() {
        audioData = nil
        updateViews()
    }

    private func setUpPlayer() {
        if let data = audioData {
            audioPlayerControl.loadAudio(from: data)
        }
        updateViews()
    }

    private func createPost() {
        view.endEditing(true)
        guard
            let data = audioRecordererControl.audioData,
            let title = titleTextField.text, title != ""
            else {
                presentInformationalAlertController(
                    title: "Uh-oh",
                    message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        postController.createPost(
            with: title,
            ofType: .audio,
            mediaData: data
        ) { success in
            DispatchQueue.main.async {
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.presentInformationalAlertController(
                        title: "Error",
                        message: "Unable to create post. Try again.")
                }
            }
        }
    }
}

// MARK: - AudioRecorderControlDelegate

extension AudioPostViewController: AudioRecorderControlDelegate {
    func audioRecorderControl(
        _ recorderControl: AudioRecorderControl,
        didFinishRecordingSucessfully didFinishRecording: Bool
    ) {
        self.audioData = recorderControl.audioData
    }
}
