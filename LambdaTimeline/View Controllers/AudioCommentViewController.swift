//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Firebase
import UIKit

class AudioCommentViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    
    var post: Post?
    var postController: PostController?
    let manager = AudioManager()
    var fileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
    }
    
    private func updateViews() {
        let recordButtonImage = manager.isRecording ? "stop.circle" : "mic.circle.fill"
        recordButton.setImage(UIImage(systemName: recordButtonImage), for: .normal)
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        manager.toggleRecordingMode()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let fileURL = fileURL,
            let commentData = try? Data(contentsOf: fileURL),
            let postController = postController,
            var post = post,
            let title = commentTextField.text,
            !title.isEmpty else { return }
        postController.addComment(with: title, and: commentData, to: &post)
        self.dismiss(animated: true)
    }
}


extension AudioCommentViewController: AudioManagerDelegate {
    func didUpdate() {
        return
    }
    
    func didPlay() {
        return
    }
    
    func didPause() {
        return
    }
    
    func didFinishPlaying() {
        return
    }
    
    func isRecording() {
        updateViews()
    }
    
    func doneRecording(with url: URL) {
        updateViews()
        self.fileURL = url
    }
}
