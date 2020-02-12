//
//  RecordingViewController.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var TitleTextField: UITextField!
    var videoPost: VideoPost?
    var postController: PostController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
    }
    
    
    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard let title = TitleTextField.text, !title.isEmpty else { return }
        postController.createPost(with: title, ofType: .video, mediaData: Data())
    }
    
    
}
