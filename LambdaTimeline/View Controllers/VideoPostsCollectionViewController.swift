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

    override func viewDidLoad() {
        super.viewDidLoad()
        postController.observeVideoPosts { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postController.videoPosts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPostCell", for: indexPath)
        let post = postController.videoPosts[indexPath.row]
        return cell
    }
}
