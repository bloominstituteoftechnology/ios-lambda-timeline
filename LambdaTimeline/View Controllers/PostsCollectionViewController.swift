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

    private let postController = PostController()
    private var operations = [String : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postController.observePosts { (_) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func addPost(_ sender: Any) {
        let alert = UIAlertController(
            title: "New Post",
            message: "Which kind of post do you want to create?",
            preferredStyle: .actionSheet)
        
        let imagePostAction = UIAlertAction(title: "Image", style: .default) { _ in
            self.performSegue(withIdentifier: "AddImagePost", sender: nil)
        }
        let audioPostAction = UIAlertAction(title: "Audio", style: .default) { _ in
            self.performSegue(withIdentifier: "AddAudioPost", sender: nil)
        }
        let videoPostAction = UIAlertAction(title: "Video", style: .default) { _ in
            self.performSegue(withIdentifier: "AddVideoPost", sender: nil)
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        
        alert.addAction(imagePostAction)
        alert.addAction(audioPostAction)
        alert.addAction(videoPostAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CollectionView DataSource
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return postController.posts.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let post = postController.posts[indexPath.row]

        var cell: PostCollectionViewCell?
        switch post.mediaType {
        case .image:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ImagePostCell",
                for: indexPath)
                as? ImagePostCollectionViewCell
        case .audio:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AudioPostCell",
                for: indexPath)
                as? AudioPostCollectionViewCell
        case .video:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "VideoPostCell",
                for: indexPath)
                as? VideoPostCollectionViewCell
        }
        guard let postCell = cell else { return PostCollectionViewCell() }

        if let manageable = postCell.avManageable {
            AVManager.shared.add(manageable)
        }
        postCell.post = post
        loadPostMedia(for: postCell, at: indexPath)

        return postCell
    }

    // MARK: - CollectionView Delegate

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let cell = collectionView.cellForItem(at: indexPath)

        if let cell = cell as? ImagePostCollectionViewCell,
            cell.imageView.image != nil {
            self.performSegue(withIdentifier: "ViewImagePost", sender: nil)
        } else if let cell = cell as? AudioPostCollectionViewCell,
            cell.audioPlayerControl.audioIsLoaded {
            self.performSegue(withIdentifier: "ViewAudioPost", sender: nil)
        } else if let cell = cell as? VideoPostCollectionViewCell,
            cell.videoPreviewView.videoIsLoaded {
            self.performSegue(withIdentifier: "ViewVideoPost", sender: nil)
        }
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard let postID = postController.posts[indexPath.row].id else { return }
        operations[postID]?.cancel()
        let cell = collectionView.cellForItem(at: indexPath) as? PostCollectionViewCell
        cell?.avManageable?.pause()
    }

    // MARK: - CollectionView Layout
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        var size = CGSize(width: view.frame.width, height: view.frame.width)
        
        let post = postController.posts[indexPath.row]

        switch post.mediaType {
        case .image(let ratio), .video(let ratio):
            if let ratio = ratio {
                size.height = size.width * ratio
            }
        default:
            size.height = 220
        }
        
        return size
    }

    // MARK: - Helper Methods
    
    private func loadPostMedia(
        for postCell: PostCollectionViewCell,
        at indexPath: IndexPath
    ) {
        let post = postController.posts[indexPath.row]
        
        guard let postID = post.id else { return }
        
        if let mediaData = cache.value(for: postID) {
            setMediaData(mediaData, for: postCell)
            return
        }
        
        let fetchOp = FetchPostMediaOperation(post: post, postController: postController)
        
        let cacheOp = BlockOperation { [weak self] in
            if let data = fetchOp.mediaData {
                self?.cache.cache(value: data, for: postID)
                DispatchQueue.main.async {
                    self?.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        let completionOp = BlockOperation { [weak self] in
            defer { self?.operations.removeValue(forKey: postID) }
            
            if let currentIndexPath = self?.collectionView?.indexPath(for: postCell),
                currentIndexPath != indexPath {
                print("Got data for now-reused cell")
                return
            }
            
            if let data = fetchOp.mediaData {
                self?.setMediaData(data, for: postCell)
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[postID] = fetchOp
    }

    private func setMediaData(
        _ mediaData: Data,
        for postCell: PostCollectionViewCell
    ) {
        if let imageCell = postCell as? ImagePostCollectionViewCell,
            let image = UIImage(data: mediaData) {
            imageCell.setImage(image)
        } else if let audioCell = postCell as? AudioPostCollectionViewCell {
            audioCell.audioPlayerControl.loadAudio(from: mediaData)
        } else if let videoCell = postCell as? VideoPostCollectionViewCell {
            do {
                try videoCell.videoPreviewView.loadVideo(data: mediaData)
            } catch {
                print("Error setting up video collection view cell: \(error)")
            }
        }
//        collectionView.reloadItems(at: [indexPath])
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        AVManager.shared.pauseAll()
        
        if let postDetailVC = segue.destination as? PostDetailViewController {
            guard
                let indexPath = collectionView.indexPathsForSelectedItems?.first,
                let postID = postController.posts[indexPath.row].id
                else { return }

            postDetailVC.postController = postController
            postDetailVC.post = postController.posts[indexPath.row]
            postDetailVC.mediaData = cache.value(for: postID)
        }
        if segue.identifier == "AddImagePost" {
            let destinationVC = segue.destination as? ImagePostViewController
            destinationVC?.postController = postController
        } else if segue.identifier == "AddAudioPost" {
            let destinationVC = segue.destination as? AudioPostViewController
            destinationVC?.postController = postController
        } else if segue.identifier == "AddVideoPost" {
            let destinationVC = segue.destination as? VideoPostViewController
            destinationVC?.postController = postController
        }
    }
}
