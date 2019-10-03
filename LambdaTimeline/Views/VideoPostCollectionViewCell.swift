//
//  ImagePostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class VideoPostCollectionViewCell: UICollectionViewCell {

	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var authorLabel: UILabel!
	@IBOutlet private weak var labelBackgroundView: UIView!
	@IBOutlet private weak var videoPlayerView: VideoPlayerView!

	override func layoutSubviews() {
		super.layoutSubviews()
		setupLabelBackgroundView()
	}
	override func prepareForReuse() {
		super.prepareForReuse()

		titleLabel.text = ""
		authorLabel.text = ""
		videoPlayerView.shouldLoop = false
		videoPlayerView.stop()
		videoPlayerView.isHidden = true
	}

	func updateViews() {
		guard let post = post else { return }

		titleLabel.text = post.title
		authorLabel.text = post.author.displayName
	}

	func loadVideo(with url: URL) {
		videoPlayerView.loadMovie(url: url)
		videoPlayerView.isHidden = false
		videoPlayerView.shouldLoop = true
		videoPlayerView.play()
		videoPlayerView.volume = 0
	}

	func setupLabelBackgroundView() {
		labelBackgroundView.layer.cornerRadius = 8
		labelBackgroundView.clipsToBounds = true
	}

	var post: Post? {
		didSet {
			updateViews()
		}
	}

}
