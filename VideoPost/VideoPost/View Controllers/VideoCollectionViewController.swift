//
//  VideoCollectionViewController.swift
//  VideoPost
//
//  Created by Chris Dobek on 6/3/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import AVFoundation

private let reuseIdentifier = "VideoCell"

class VideoCollectionViewController: UICollectionViewController {
    
    var thumbnails: [UIImage?] = []
    var videos: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView.reloadData()
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateVideoSegue" {
            guard let vc = segue.destination as? CameraViewController else {return}
            vc.delegate = self
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? VideoCollectionViewCell else { return UICollectionViewCell() }
        
        
        cell.thumbnail = thumbnails[indexPath.item]
    
        return cell
    }

   func createThumbnail(url : URL) -> UIImage? {

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
