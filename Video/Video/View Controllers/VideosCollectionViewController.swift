//
//  VideosCollectionViewController.swift
//  Video
//
//  Created by Wyatt Harrell on 5/6/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit

class VideosCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWatchVideoSegue" {
            guard let WatchVideoVC = segue.destination as? WatchVideoViewController else { return }
            guard let selected = collectionView.indexPathsForSelectedItems else { return }
            WatchVideoVC.recordingURL = videoController.videos[selected[0].row].recordingURL
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return videoController.videos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoCollectionViewCell else { return UICollectionViewCell() }
    
        cell.video = videoController.videos[indexPath.item]
        cell.layer.cornerRadius = 8
        return cell
    }
}
