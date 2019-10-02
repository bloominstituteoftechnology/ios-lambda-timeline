//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentTableViewCell: UITableViewCell {

	@IBOutlet private var authorLabel: UILabel!
	@IBOutlet private var playPauseButton: UIButton!
	@IBOutlet private var progressSlider: UISlider!
	@IBOutlet private var timeProgressLabel: UILabel!

	var comment: Comment?

	private lazy var timeFormatter: DateComponentsFormatter = {
		let formatting = DateComponentsFormatter()
		formatting.unitsStyle = .positional // 00:00
		formatting.zeroFormattingBehavior = .pad
		formatting.allowedUnits = [.minute, .second]
		return formatting
	}()

	override func awakeFromNib() {
		super.awakeFromNib()
		timeProgressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
	}


	@IBAction func playPauseButtonPressed(_ sender: UIButton) {
	}

}
