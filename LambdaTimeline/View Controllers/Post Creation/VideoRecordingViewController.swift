//
//  VideoRecordingViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class VideoRecordingViewController: UIViewController {
	/// hide this when video is recording - makes it really hard to accidentally NOT record
	@IBOutlet private var indicatorContainer: UIView!
	@IBOutlet private var recordButton: UIButton!
	@IBOutlet private var playbackButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		recordButton.tintColor = .systemRed
		playbackButton.tintColor = .systemGreen
	}

	@IBAction func recordButtonDown(_ sender: UIButton) {
		indicatorContainer.isHidden = true
	}

	@IBAction func recordButtonUp(_ sender: UIButton) {
		indicatorContainer.isHidden = false
	}

	@IBAction func playButtonPressed(_ sender: UIButton) {
	}

}
