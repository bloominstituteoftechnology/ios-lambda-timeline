//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol AudioCommentViewControllerDelegate: AnyObject {
    func didSuccessfullyLeaveAudioComment()
}

class AudioCommentViewController: UIViewController {

    var post: Post!
    var postController: PostController!
    weak var delegate: AudioCommentViewControllerDelegate?

    var audioData: Data?

    @IBOutlet weak var recorderControl: AudioRecorderControl!
    @IBOutlet weak var playerControl: AudioPlayerControl!
    @IBOutlet weak var reRecordButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        recorderControl.delegate = self
        updateViews()
    }

    // MARK: - Actions

    @IBAction
    func reRecordButtonTapped(_ sender: UIButton) {
        clearRecordedData()
    }

    @IBAction
    func submitButtonTapped(_ sender: UIButton) {
        submitComment()
    }

    func clearRecordedData() {
        audioData = nil
        updateViews()
    }

    func submitComment() {
        guard let data = audioData else { return }
        postController.addComment(withAudioData: data, to: post)
        { [weak self] success in
            guard success else {
                DispatchQueue.main.async {
                    self?.presentInformationalAlertController(
                        title: "Failed to add comment.",
                        message: "Sorry! There was an error. Try again maybe?",
                        dismissActionCompletion: nil,
                        completion: nil)
                }
                return
            }
            self?.delegate?.didSuccessfullyLeaveAudioComment()
        }
    }

    // MARK: - Helper Methods

    private func updateViews() {
        let hasRecordedData = (audioData != nil)
        recorderControl.isHidden = hasRecordedData
        playerControl.isHidden = !hasRecordedData
        reRecordButton.isHidden = !hasRecordedData
        submitButton.isEnabled = hasRecordedData
    }

    private func setUpPlayer() {
        if let data = audioData {
            playerControl.loadAudio(from: data)
        }
        updateViews()
    }
}

// MARK: - AudioRecorderControlDelegate

extension AudioCommentViewController: AudioRecorderControlDelegate {
    func audioRecorderControl(
        _ recorderControl: AudioRecorderControl,
        didFinishRecordingSucessfully didFinishRecording: Bool
    ) {
        self.audioData = recorderControl.audioData
        setUpPlayer()
    }
}
