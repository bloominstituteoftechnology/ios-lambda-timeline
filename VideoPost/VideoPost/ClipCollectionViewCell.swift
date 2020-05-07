//
//  ClipCollectionViewCell.swift
//  VideoPost
//
//  Created by Mark Gerrior on 5/6/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
//

import UIKit

class ClipCollectionViewCell: UICollectionViewCell {

    // MARK: - Properites
    var clipName: String? {
        didSet {
            clipNameLabel.text = clipName
        }
    }

    var thumbnail: UIImage? {
        didSet {
            thumbnailView.image = thumbnail
        }
    }
    // MARK: - Actions

    // MARK: - Outlets

    @IBOutlet weak var clipNameLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!

    // MARK: - Private

}
