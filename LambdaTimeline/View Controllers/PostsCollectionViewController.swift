//
//  PostsCollectionViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import Photos
import ImageIO
import AVKit
import AVFoundation
import MobileCoreServices

class PostsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postController.observePosts { (_) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func addPost(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Post", message: "Which kind of post do you want to create?", preferredStyle: .actionSheet)
        
        let imagePostAction = UIAlertAction(title: "Image", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddImagePost", sender: nil)
        }
        let videoPostAction = UIAlertAction(title: "Make Video", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddVideoPost", sender: nil)
        }
        let videoToAddAction = UIAlertAction(title: "Add Video", style: .default) { (_) in
            let authorizationStatus = PHPhotoLibrary.authorizationStatus()
            
            switch authorizationStatus {
            case .authorized:
                self.presentPhotoPickerController()
            case .notDetermined:
                
                PHPhotoLibrary.requestAuthorization { (status) in
                    
                    guard status == .authorized else {
                        NSLog("User did not authorize access to the photo library")
                        self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                        return
                    }
                    
                    self.presentPhotoPickerController()
                }
                
            case .denied:
                self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
            case .restricted:
                self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
                
            }
            self.presentPhotoPickerController()
        }
        
            
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(videoToAddAction)
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
            
        case .image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCell", for: indexPath) as? ImagePostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.post = post
            
            loadImage(for: cell, forItemAt: indexPath)
            
            return cell
        default:
          return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize(width: view.frame.width, height: view.frame.width)
        
        let post = postController.posts[indexPath.row]
        
        switch post.mediaType {
            
        case .image:
            
            guard let ratio = post.ratio else { return size }
            
            size.height = size.width * ratio
        default:
            break
        }
        
        return size
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if let cell = cell as? ImagePostCollectionViewCell,
            cell.imageView.image != nil {
            self.performSegue(withIdentifier: "ViewImagePost", sender: nil)
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
        
        let fetchOp = FetchMediaOperation(post: post, postController: postController)
        
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
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddImagePost" {
            let destinationVC = segue.destination as? ImagePostViewController
            destinationVC?.postController = postController
            
        } else if segue.identifier == "ViewImagePost" {
            
            let destinationVC = segue.destination as? ImagePostDetailTableViewController
            
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                let postID = postController.posts[indexPath.row].id else { return }
            
            destinationVC?.postController = postController
            destinationVC?.post = postController.posts[indexPath.row]
            destinationVC?.imageData = cache.value(for: postID)
        }
    }
    
    private func presentPhotoPickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["kUTTypeMovie"]
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    private let postController = PostController()
    private var operations = [String : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()
}


extension PostsCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func galleryVideo()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            
            let videoPicker = UIImagePickerController()
            videoPicker.delegate = self
            videoPicker.sourceType = .photoLibrary
            videoPicker.mediaTypes = [kUTTypeMovie as String]
            self.present(videoPicker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }



}
