//
//  VideosCollectionViewController.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/14/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class VideosCollectionViewController: UICollectionViewController {

    //MARK:- Properties
    var posts: [Post] = []
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(VideosCollectionViewCell.self,
                                      forCellWithReuseIdentifier: "videoCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    //MARK: - IBACtion
    @IBAction func addNewVideo(_ sender: Any) {
        requestPermissionAndShowCamera()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailViewSegue" {
            guard let detailVC = segue.destination as? CameraViewController else { return }
            detailVC.delegate = self
        } else if segue.identifier == "showMapViewSegue" {
            if let destinationVC = segue.destination as? LocationViewController {
                destinationVC.posts = posts
            }
        }
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as? VideosCollectionViewCell else { return UICollectionViewCell() }
    
        cell.post = posts[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize(width: view.frame.width, height: view.frame.width)
        let post = posts[indexPath.row]
        
        guard let ratio = post.ratio else { return size }
            
        size.height = size.width * ratio
        
        return size
    }

    
    func createThumbnail(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        let cgImage = try? imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        if let cgImage = cgImage{
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        }
        return nil
    }

}

//MARK: - Extension
extension VideosCollectionViewController: CameraViewControllerDelegate {
    func didSaveVideo(at url: URL, postTitle: String, location: CLLocationCoordinate2D?, image: UIImage) {
        let post = Post(postTitle: postTitle, mediaURL: url, location: location, image: image)
        posts.append(post)
        collectionView.reloadData()
    }
}

extension VideosCollectionViewController {
    
    private func requestPermissionAndShowCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined: // 1st run and the user hasn't been asked to give permission
            requestVideoPermission()
            
        case .restricted: // Parental controls, for instance, are preventing recording
            preconditionFailure("Video is disabled, please review device restrictions")
            
        case .denied: // 2nd+ run, the user didn't trust us, or they said no by accident (show how to enable)
            preconditionFailure("Tell the user they can't use the app without giving permissions via Settings > Privacy > Video")
            
        case .authorized: // 2nd+ run, the user has given the app permission to use the camera
            showCamera()
        
        @unknown default:
            preconditionFailure("A new status code for AVCaptureDevice authorization was added that we need to handle")
        }
    }

    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { isGranted in
            guard isGranted else {
                preconditionFailure("UI: Tell the user to enable permissions for Video/Camera")
            }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "createVideoSegue", sender: self)
    }
}

