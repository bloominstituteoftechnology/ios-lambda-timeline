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

    var videoClip: [(String, URL)] = []
    var imageview: [UIImage?] = []
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(VideosCollectionViewCell.self,
                                      forCellWithReuseIdentifier: "videoCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailViewSegue" {
            guard let detailVC = segue.destination as? CameraViewController else { return }
            detailVC.delegate = self
        }
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as? VideosCollectionViewCell else { return UICollectionViewCell() }
        
//        cell.clipName = videoClip[indexPath.item].0
//        cell.imageName = imageview[indexPath.item]
    
        cell.post = posts[indexPath.row]
        return cell
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
