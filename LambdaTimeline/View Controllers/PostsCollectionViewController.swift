//
//  PostsCollectionViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVKit

class PostsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var geotagButton: UIBarButtonItem!
    
    var postController: PostController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
    @IBAction func toggleGeotagging(_ sender: UIBarButtonItem) {
        if postController.geotagging {
            postController.geotagging = false
            geotagButton.title = "Geotagging Off"
        } else {
            postController.geotagging = true
            geotagButton.title = "Geotagging On"
        }
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
        return postController?.posts.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let post = postController.posts[indexPath.row]
        
        switch post.mediaType {
            
        case .image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCell", for: indexPath) as? ImagePostCollectionViewCell else { return UICollectionViewCell() }
            cell.post = post
            return cell
        case .video(let videoURL):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPostCell", for: indexPath) as? VideoPostCollectionViewCell else { return UICollectionViewCell() }
            cell.post = post
            let player = AVPlayer(url: videoURL)
            cell.playerView.player = player
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize(width: view.frame.width, height: view.frame.width)
        
        let post = postController.posts[indexPath.row]
        
        guard let ratio = post.ratio else { return size }
        
        size.height = size.width * ratio
        
        return size
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            self.performSegue(withIdentifier: "ViewImagePost", sender: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddImagePost" {
            let destinationVC = segue.destination as? ImagePostViewController
            destinationVC?.postController = postController
            
        } else if segue.identifier == "ViewImagePost" { // Also serves Video Posts
            let destinationVC = segue.destination as? ImagePostDetailTableViewController
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
            destinationVC?.postController = postController
            destinationVC?.post = postController.posts[indexPath.row]
            
        } else if segue.identifier == "AddVideoPost" {
            let destinationVC = segue.destination as? CameraViewController
            destinationVC?.postController = postController
        }
    }
}
