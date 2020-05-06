//
//  CommentContainerViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class CommentContainerViewController: UIViewController {

	@IBOutlet private var backgroundView: UIView!
	@IBOutlet private var pageViewContainer: UIView!

	var postController: PostController?
	var post: Post?

	override func viewDidLoad() {
		super.viewDidLoad()
		pageViewContainer.layer.shadowColor = UIColor.black.cgColor
		pageViewContainer.layer.shadowRadius = 20
		pageViewContainer.layer.shadowOpacity = 0.5
		pageViewContainer.subviews.first?.layer.cornerRadius = 20
	}

	@IBAction func backgroundViewTapped(_ sender: UITapGestureRecognizer) {
		dismiss(animated: true)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let navController = segue.destination as? CommentNavController {
			navController.postController = postController
			navController.post = post
			navController.navDelegate = self
		}
	}
}

extension CommentContainerViewController: CommentNavControllerDelegate {
	func commentNavControllerDidFinish(_ cnVC: CommentNavController) {
		dismiss(animated: true)
	}
}
