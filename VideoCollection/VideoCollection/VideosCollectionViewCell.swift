//
//  VideosCollectionViewCell.swift
//  VideoCollection
//
//  Created by Bhawnish Kumar on 6/3/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

class VideosCollectionViewCell: UICollectionViewCell {
    var videoClip: URL!
    
    var clipName: String? {
        didSet {
        titleLabel.text = clipName
        }
    }
    
    var imageName: UIImage? {
        didSet {
            imageView.image = imageName
        }
    }

    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
}
