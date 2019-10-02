//
//  ProseCommentViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class ProseCommentViewController: UIViewController {

	@IBOutlet private var commentTextView: UITextView!

	var commentText: String {
		commentTextView.text ?? "No comment"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		commentTextView.layer.cornerRadius = 10
		commentTextView.layer.borderColor = UIColor.lightGray.cgColor
		commentTextView.layer.borderWidth = 2
		commentTextView.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
	}
}
