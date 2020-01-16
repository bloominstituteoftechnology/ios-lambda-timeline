//
//  VideoPostViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class VideoPostViewController: UIViewController {

    var mediaData: Data?

    @IBOutlet weak var videoView: VideoPreviewView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
    }

    func updateViews() {
        
    }
    
    // MARK: - Actions

    @IBAction
    func recordButtonTapped(_ sender: Any) {
        recordNewVideo()
    }

    @IBAction
    func postButtonTapped(_ sender: Any) {
        postVideo()
    }

    func recordNewVideo() {
        performSegue(withIdentifier: "RecordVideoSegue", sender: self)
    }

    func postVideo() {

    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordVideoSegue" {
            guard let videoRecorderVC = segue.destination
                as? VideoRecorderViewController
                else { return }
            videoRecorderVC.delegate = self
        }
    }
}

// MARK: - VideoRecorder Delegate

extension VideoPostViewController: VideoRecorderDelegate {
    func videoRecorderVC(
        _ videoRecorderVC: VideoRecorderViewController,
        didFinishRecordingSucessfully success: Bool,
        toURL videoURL: URL
    ) {
        guard success else { return }
        videoView.setUpVideoAndPlay(url: videoURL)
    }
}
