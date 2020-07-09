//
//  PostsCollectionViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseUI

class PostsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    @IBOutlet weak var geotagSwitch: UISwitch!
    
    // MARK: - Properties
    private var operations = [String : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()
    private let cacheVideoThumbnail = Cache<String, UIImage>()
    private let cacheVideoURL = Cache<String, URL>()
    private let locationManager = LocationManager()
    
    var postController: PostController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.setUp()
        
        self.postController.observePosts { (_) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func toggleGeotag(_ sender: Any) {
        self.locationManager.shouldSendGeotag = geotagSwitch.isOn
    }
    
    @IBAction func addPost(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Post", message: "Which kind of post do you want to create?", preferredStyle: .actionSheet)
        
        let imagePostAction = UIAlertAction(title: "Image", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddImagePost", sender: nil)
        }
        
        let videoPostAction = UIAlertAction(title: "Video", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddVideoPost", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(imagePostAction)
        alert.addAction(videoPostAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = postController.posts[indexPath.row]
        
        switch post.mediaType {
        case .image, .audio:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCell", for: indexPath) as? ImagePostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.post = post
            
            loadImage(for: cell, forItemAt: indexPath)
            
            return cell
        case .video:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCell", for: indexPath) as? ImagePostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.post = post
            
            loadVideo(for: cell, forItemAt: indexPath)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize(width: view.frame.width, height: view.frame.width)
        
        let post = postController.posts[indexPath.row]
        
        switch post.mediaType {
        case .image:
            guard let ratio = post.ratio else { return size }
            size.height = size.width * ratio
        case .audio:
            break
        case .video:
            break
        }
        return size
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let post = postController.posts[indexPath.row]
        
        if post.mediaType == .image {
            self.performSegue(withIdentifier: "ViewImagePost", sender: nil)
        } else if post.mediaType == .video {
            self.performSegue(withIdentifier: "ViewVideoPost", sender: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        guard let postID = postController.posts[indexPath.row].id else { return }
        operations[postID]?.cancel()
    }
    
    func loadImage(for imagePostCell: ImagePostCollectionViewCell, forItemAt indexPath: IndexPath) {
        let post = postController.posts[indexPath.row]
        
        guard let postID = post.id else { return }
        
        if let mediaData = cache.value(for: postID),
            let image = UIImage(data: mediaData) {
            imagePostCell.setImage(image)
            self.collectionView.reloadItems(at: [indexPath])
            return
        }
        
        let fetchOp = FetchMediaOperation(url: post.mediaURL)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.mediaData {
                self.cache.cache(value: data, for: postID)
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: postID) }
            
            if let currentIndexPath = self.collectionView?.indexPath(for: imagePostCell),
                currentIndexPath != indexPath {
                print("Got image for now-reused cell")
                return
            }
            
            if let data = fetchOp.mediaData {
                imagePostCell.setImage(UIImage(data: data))
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[postID] = fetchOp
    }
    
    func loadVideo(for imagePostCell: ImagePostCollectionViewCell, forItemAt indexPath: IndexPath) {
        let post = postController.posts[indexPath.row]
        
        guard let postID = post.id else { return }
        
        if let mediaThumbnail = cacheVideoThumbnail.value(for: postID) {
            imagePostCell.setImage(mediaThumbnail)
            self.collectionView.reloadItems(at: [indexPath])
            return
        }
        
        let fetchOp = FetchMediaOperation(url: post.mediaURL)
        
        let completionOp = BlockOperation {
            if let data = fetchOp.mediaData {
                let directory = NSTemporaryDirectory()
                let fileName = "\(NSUUID().uuidString).mov"
                guard let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName]) else {
                    return
                }
                    
                do {
                    try data.write(to: fullURL)
                    let asset = AVAsset(url: fullURL)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    
                    self.cacheVideoThumbnail.cache(value: thumbnail, for: postID)
                    
                    // to send it to the detail segue
                    self.cacheVideoURL.cache(value: fullURL, for: postID)
                    
                    imagePostCell.setImage(thumbnail)
                } catch let error {
                    print("Error generating thumbnail: \(error.localizedDescription)")
                }
            }
        }
        
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        OperationQueue.main.addOperation(completionOp)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddImagePost" {
            let destinationVC = segue.destination as? ImagePostViewController
            destinationVC?.postController = self.postController
            destinationVC?.locationManager = self.locationManager
            
        } else if segue.identifier == "AddVideoPost" {
            let destinationVC = segue.destination as? CameraViewController
            destinationVC?.postController = self.postController
            destinationVC?.locationManager = self.locationManager
            
        } else if segue.identifier == "ViewImagePost" {
            
            let destinationVC = segue.destination as? ImagePostDetailTableViewController
            
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                let postID = self.postController.posts[indexPath.row].id else { return }
            
            destinationVC?.postController = postController
            destinationVC?.post = postController.posts[indexPath.row]
            destinationVC?.imageData = cache.value(for: postID)

        } else if segue.identifier == "ViewVideoPost" {
            let destinationVC = segue.destination as? VideoPostDetailTableViewController
            
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                let postID = postController.posts[indexPath.row].id else { return }
            
            destinationVC?.postController = postController
            destinationVC?.post = postController.posts[indexPath.row]
            destinationVC?.videoURL = cacheVideoURL.value(for: postID)
        }
    }
}
