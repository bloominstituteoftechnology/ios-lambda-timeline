//
//  VideoPostsCollectionViewController.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit


class VideoPostsCollectionViewController: UICollectionViewController {
    
    private let postController = PostController()
    private var videoPost: VideoPost?
    private var operations = [String : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()

    override func viewDidLoad() {
        super.viewDidLoad()
        postController.observeVideoPosts { (_) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowVidoeRecoderSegue":
            guard let destinatioVC = segue.destination as? RecordingViewController else { return }
            destinatioVC.postController = postController
        case "ShowImagePostDetailSegue":
            guard let imagePostDetailVC = segue.destination as? ImagePostDetailTableViewController else { return }
            imagePostDetailVC.postController = postController
            imagePostDetailVC.videoPost = videoPost
        default:
            break
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return postController.videoPost.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPostCell", for: indexPath) as? VideoPostCollectionViewCell else { return UICollectionViewCell() }
        
        let post = postController.videoPost[indexPath.row]
        cell.videoPost = post 
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoPost = postController.videoPost[indexPath.item]
        self.videoPost = videoPost
        performSegue(withIdentifier: "ShowImagePostDetialSegue", sender: self)
    }
    
    @IBAction func addVideoPostTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Post", message: nil, preferredStyle: .actionSheet)
        let videoPostAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            self.performSegue(withIdentifier: "ShowVidoeRecoderSegue", sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(videoPostAction)
        alert.addAction(cancelAction)
        self.present(alert,animated: true)
    }
    

}
