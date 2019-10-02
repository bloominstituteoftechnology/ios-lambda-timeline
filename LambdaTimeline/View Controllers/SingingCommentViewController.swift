//
//  SingingCommentViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SingingCommentViewController: UIViewController {

	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private var recordButton: UIButton!
	@IBOutlet private var previewButton: UIButton!


	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		// TODO: cancel if recording during a swipe
	}


	@IBAction func recordButtonPressed(_ sender: UIButton) {
		activityIndicator.isHidden.toggle()
	}

	@IBAction func previewButtonPressed(_ sender: UIButton) {
	}

}
