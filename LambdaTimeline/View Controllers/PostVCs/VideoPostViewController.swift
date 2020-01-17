//
//  VideoPostViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostViewController: PostViewController {

    var localVideoURL: URL?

    override var mediaData: Data? {
        if let url = localVideoURL {
            return try? Data(contentsOf: url)
        } else { return nil }
    }
    override var avManageable: AVManageable? { videoView }

    @IBOutlet weak var videoView: VideoPlayerView!
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: - Actions

    @IBAction
    func recordButtonTapped(_ sender: Any) {
        recordNewVideo()
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

    override func createPost() {
        if let data = mediaData {
            createPost(ofType: .video(ratio: nil), with: data)
        } else {
            presentInformationalAlertController(
                title: "Uh-oh",
                message: "Make sure that you record a video before posting.")
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
