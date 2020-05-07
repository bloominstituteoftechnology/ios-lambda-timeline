//
//  VideoPostsCollectionViewController.swift
//  VideoPosts
//
//  Created by Tobi Kuyoro on 06/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostsCollectionViewController: UICollectionViewController {

    let recordingController = RecordingController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }

    // MARK: - IBActions

    @IBAction func cameraButtonTapped(_ sender: Any) {
        requestPermissionAndShowCamera()
    }

    // MARK: - Actions

    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
            case .notDetermined:
                requestPermission()
            case .restricted:
                fatalError("Tell user they need to request permission from parent UI")
            case .denied:
                fatalError("Tell user to enable in Settings: Popup from Audio to do this, or use a custom view")
            case .authorized:
                showCamera()
            default:
                fatalError("Handle new case for authorization")
        }
    }

    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                fatalError("Tell user to enable in Settings: Popup from Audio to do this, or use a custom view")
            }

            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }

    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCamera" {
            if let cameraVC = segue.destination as? CameraViewController {
                cameraVC.recordingController = recordingController
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordingController.recordings.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordingCell", for: indexPath) as? RecordingCollectionViewCell else {
            return UICollectionViewCell()
        }

        let recording = recordingController.recordings[indexPath.item]
        cell.recording = recording

        return cell
    }
}
