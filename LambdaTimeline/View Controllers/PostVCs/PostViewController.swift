//
//  PostViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-16.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class PostViewController: ShiftableViewController {
    var post: Post?
    var postController: PostController!

    var mediaData: Data? { return nil }

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var geotagSwitch: UISwitch!

    @IBAction func createPostButtonTapped(_ sender: Any) {
        createPost()
    }

    func createPost() {}

    func createPost(ofType mediaType: MediaType, with data: Data) {
        view.endEditing(true)
        guard
            let title = titleTextField.text, title != ""
            else {
                presentInformationalAlertController(
                    title: "Uh-oh",
                    message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        postController.createPost(
            with: title,
            ofType: mediaType,
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

    @IBAction
    func geotagSwitchChanged(_ sender: UISwitch) {

    }
}
