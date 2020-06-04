//
//  VideoCollectionViewCell.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/4/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var videoTime: Double? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let videoTime = videoTime else { return }
                
        imageView.image = UIImage(named: "Movie")
        timeLabel.text = "\(videoTime)"
    }
}
