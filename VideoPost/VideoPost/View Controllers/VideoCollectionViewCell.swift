//
//  VideoCollectionViewCell.swift
//  VideoPost
//
//  Created by Chris Dobek on 6/3/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properites
    var thumbnail: UIImage? {
        didSet {
            thumbnailView.image = thumbnail
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var thumbnailView: UIImageView!
    
}
