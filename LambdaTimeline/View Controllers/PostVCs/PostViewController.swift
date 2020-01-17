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
    var locationHelper = LocationHelper()

    var mediaData: Data? { return nil }

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var geotagSwitch: UISwitch!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if locationHelper.hasLocationPermission == nil {
            locationHelper.requestLocationPermission()
        }
        if let hasLocationPermission = locationHelper.hasLocationPermission,
            !hasLocationPermission {
            geotagSwitch.isEnabled = false
            locationHelper.beginUpdatingLocation()
        }
    }

    deinit {
        locationHelper.stopUpdatingLocation()
    }

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
        let location = geotagSwitch.isOn ? locationHelper.currentLocation : nil

        postController.createPost(
            with: title,
            ofType: mediaType,
            mediaData: data,
            geotag: location
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
