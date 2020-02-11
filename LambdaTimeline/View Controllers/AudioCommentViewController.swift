//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Firebase
import UIKit

class AudioCommentViewController: UIViewController {
    
    
    @IBOutlet weak var recordButton: UIButton!
    
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

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
    }
    
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let fileURL = fileURL,
            let commentData = try? Data(contentsOf: fileURL),
            let postController = postController,
            var post = post else { return }
        postController.addComment(with: "", and: commentData, to: &post)
        
    }
    
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        manager.toggleRecordingMode()
    }
    
}

extension AudioCommentViewController: AudioManagerDelegate {
    
    func isRecording() {
        updateViews()
    }
    
    func doneRecording(with url: URL) {
        updateViews()
        self.fileURL = url
    }
    
    
}
