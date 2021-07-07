//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Vici Shaweddy on 1/17/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol AudioCommentViewControllerDelegate: AnyObject {
    func didSave()
}

class AudioCommentViewController: UIViewController {
    
    // MARK: - Properties
    let recordController = RecordController()
    let postController = PostController()
    var post: Post?
    weak var delegate: AudioCommentViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    @IBAction func recordPressed(_ sender: Any) {
        if recordController.isRecording {
            self.recordController.stopRecording()
        } else {
            self.recordController.startRecording()
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard let url = self.recordController.audioURL,
            let post = self.post else { return }
        
        self.postController.addComment(with: .audio(url), to: post) {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didSave()
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
