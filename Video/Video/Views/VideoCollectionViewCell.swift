//
//  VideoCollectionViewCell.swift
//  Video
//
//  Created by Wyatt Harrell on 5/6/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var video: Video? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let video = video else { return }
        videoNameLabel.text = video.name
        
        getThumbnailImageFromVideoUrl(url: video.recordingURL) { (image) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }

    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
}
