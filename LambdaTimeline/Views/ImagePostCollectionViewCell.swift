//
//  ImagePostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
//swiftlint:disable private_outlet

import UIKit

class ImagePostCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var authorLabel: UILabel!
	@IBOutlet private weak var labelBackgroundView: UIView!

	override func layoutSubviews() {
		super.layoutSubviews()
		setupLabelBackgroundView()
	}
	override func prepareForReuse() {
		super.prepareForReuse()

		imageView.image = nil
		titleLabel.text = ""
		authorLabel.text = ""
	}

	func updateViews() {
		guard let post = post else { return }

		titleLabel.text = post.title
		authorLabel.text = post.author.displayName
	}

	func setupLabelBackgroundView() {
		labelBackgroundView.layer.cornerRadius = 8
//		labelBackgroundView.layer.borderColor = UIColor.white.cgColor
//		labelBackgroundView.layer.borderWidth = 0.5
		labelBackgroundView.clipsToBounds = true
	}

	func setImage(_ image: UIImage?) {
		imageView.image = image
	}

	var post: Post? {
		didSet {
			updateViews()
		}
	}

}
