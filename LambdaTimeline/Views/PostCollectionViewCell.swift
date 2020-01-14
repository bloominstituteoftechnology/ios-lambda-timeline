//
//  PostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-14.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    var post: Post? {
        didSet {
            updateViews()
        }
    }

    weak var titleLabel: UILabel!
    weak var authorLabel: UILabel!
    weak var labelBackgroundView: UIView!

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        authorLabel.text = ""
    }

    func updateViews() {
        guard let post = post else { return }

        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }

    private func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        //        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
        //        labelBackgroundView.layer.borderWidth = 0.5
        labelBackgroundView.clipsToBounds = true
    }

}
