//
//  VideosCollectionViewCell.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/14/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

class VideosCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    var videoClip: URL!
    
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    var clipName: String? {
        didSet {
            titleLabel.text = clipName
        }
    }
    
    var imageName: UIImage! {
        didSet {
            imageView.image = imageName
        }
    }
    
    func updateViews() {
        guard let post = post else { return }
        titleLabel.text = post.title
        imageView.image = post.image
    }
}
