//
//  VideoPostsCollectionViewController.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class VideoPostsCollectionViewController: UICollectionViewController {
    
    private let postController = PostController()
    private var operations = [String : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()
    private var videoPost: VideoPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        postController.observeVideoPosts { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowVideoRecorderSegue":
            guard let destinationVC = segue.destination as? RecordingViewController else { return }
            destinationVC.postController = postController
        case "ShowImagePostDetailSegue":
            guard let imagePostDetailVC = segue.destination as? ImagePostDetailTableViewController else { return }
            imagePostDetailVC.postController = postController
            imagePostDetailVC.videoPost = videoPost
        default:
            break
        }
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Post", message: nil, preferredStyle: .actionSheet)
        let videoPostAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            self.performSegue(withIdentifier: "ShowVideoRecorderSegue", sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(videoPostAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postController.videoPosts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPostCell", for: indexPath) as? VideoPostCollectionViewCell else { return UICollectionViewCell() }
        let post = postController.videoPosts[indexPath.item]
        cell.videoPost = post
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoPost = postController.videoPosts[indexPath.item]
        self.videoPost = videoPost
        performSegue(withIdentifier: "ShowImagePostDetailSegue", sender: self)
    }
}
