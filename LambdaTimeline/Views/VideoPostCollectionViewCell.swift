//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Thomas Cacciatore on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    func updateViews() {
        guard let post = post else { return }
        
       //update with video
    }

    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
}
