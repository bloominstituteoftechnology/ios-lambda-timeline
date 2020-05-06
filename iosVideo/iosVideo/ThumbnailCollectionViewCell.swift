//
//  ThumbnailCollectionViewCell.swift
//  iosVideo
//
//  Created by Karen Rodriguez on 5/6/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import AVFoundation

class ThumbnailCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    var thumbURL: URL? {
        didSet {
            getThumbnail()
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var thumbnailView: UIImageView!

    private func getThumbnail() {
        guard let url = thumbURL else {
            NSLog("Error unwrapping URL!")
            return
        }
        DispatchQueue.init(label: "Fetching thumbnail for this URL").async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    self.thumbnailView.image = thumbImage
                }
            } catch {
                NSLog("Error generating a CG image from asset at given thumbnail time. \(error)")
            }
        }
    }
    
}
