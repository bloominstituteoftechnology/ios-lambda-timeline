//
//  VideoPostViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostViewController: UIViewController {

    var localVideoURL: URL?
    var videoData: Data?

    var post: Post?
    var postController: PostController!

    @IBOutlet weak var videoView: VideoPreviewView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    
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
        checkCameraPermissions { [weak self] wasSuccessful in
            if wasSuccessful {
                self?.performSegue(withIdentifier: "RecordVideoSegue", sender: self)
            } else {
                self?.presentInformationalAlertController(
                    title: "No permissions.",
                    message: "Please make sure you allow us to use your camera in your device settings.")
            }
        }
    }

    func postVideo() {
        view.endEditing(true)

        guard
            let url = localVideoURL,
            let title = titleTextField.text, !title.isEmpty
            else {
                presentInformationalAlertController(
                    title: "Uh-oh",
                    message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        do {
            let data = try Data(contentsOf: url)

            postController.createPost(
                with: title,
                ofType: .video(ratio: nil),
                mediaData: data)
            { [weak self] success in
                DispatchQueue.main.async { [weak self] in
                    guard success else {
                        self?.presentInformationalAlertController(
                            title: "Error",
                            message: "Unable to create post. Please try again.)")
                        return
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            NSLog("\(error)")
            presentInformationalAlertController(
                title: "Error",
                message: "Unable to create post. Please try again. (Error: \(error)))")
        }
    }

    // MARK: - Private

    private func checkCameraPermissions(_ wasSuccessFul: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { permissionGranted in
                DispatchQueue.main.async { wasSuccessFul(permissionGranted) }
            }
        case .authorized:
            wasSuccessFul(true)
        default:
            wasSuccessFul(false)
        }
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
    func videoRecorder(
        didFinishRecordingSucessfully success: Bool,
        toURL videoURL: URL
    ) {
        guard success else { return }
        localVideoURL = videoURL
        DispatchQueue.main.async { [weak self] in
            self?.videoView.loadVideo(url: videoURL)
            self?.videoView.play()
        }
    }
}
