//
//  VideoCollectionViewController.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/4/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCollectionViewController: UICollectionViewController {
    
    var videos = [(URL, Double)]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
    }

    @IBAction func showCamera(_ sender: Any) {
        requestPermissionAndShowCamera()
    }
    
    func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            requestPermission()
        case .restricted:
            fatalError("Show user UI to let them know they don't have access")
        case .denied:
            fatalError("Show user UI to get them to give access")
        case .authorized:
            showCamera()
        @unknown default:
            fatalError("Apple added another enum value that we're not handling")
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                fatalError("Show user UI to get them to give access")
            }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "CameraSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CameraSegue" {
            guard let cameraVC = segue.destination as? CameraViewController else { return }
            
            cameraVC.delegate = self
        } else if segue.identifier == "PlayerSegue" {
            guard let playerVC = segue.destination as? PlayerViewController,
                let cell = sender as? VideoCollectionViewCell,
                let indexPath = collectionView.indexPath(for: cell) else { return }
            
            playerVC.videoURL = videos[indexPath.row].0
        }
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoCollectionViewCell else {
            fatalError("Messed up the reuse identifier")
        }
        
        cell.videoTime = videos[indexPath.row].1
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension VideoCollectionViewController: CameraViewDelegate {
    func didFinishRecording(to url: URL, lasting length: Double) {
        videos.append((url, length))
    }
}
