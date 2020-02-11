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

    var mediaData: Data? { nil }

    var avManageable: AVManageable? { nil }

    // MARK: - Outlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var geotagSwitch: UISwitch!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let player = avManageable { AVManager.shared.add(player) }
        titleTextField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if locationHelper.hasLocationPermission == nil {
            locationHelper.requestLocationPermission()
        }
        guard
            let hasLocationPermission = locationHelper.hasLocationPermission,
            hasLocationPermission
            else {
                geotagSwitch.isEnabled = false
                return
        }
        locationHelper.beginUpdatingLocation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationHelper.stopUpdatingLocation()
        AVManager.shared.pauseAll()
    }

    // MARK: - Action

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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
