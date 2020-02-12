//
//  RecordingViewController.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    var postController: PostController!
    var videoPost: VideoPost?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard let title = titleTextField.text, !title.isEmpty else { return }
        postController.createPost(with: title, ofType: .video, mediaData: Data())
    }
}
