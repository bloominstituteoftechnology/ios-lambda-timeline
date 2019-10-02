//
//  CommentNavController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol CommentNavControllerDelegate: AnyObject {
	func commentNavControllerDidFinish(_ cnVC: CommentNavController)
}

class CommentNavController: UINavigationController {

	var postController: PostController?
	var post: Post?

	weak var navDelegate: CommentNavControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		for vc in viewControllers.compactMap({ $0 }) {
			if let commentPageVC = vc as? CommentPageViewController {
				commentPageVC.postController = postController
				commentPageVC.post = post
				commentPageVC.navDelegate = self
			}
		}
	}
}

extension CommentNavController: CommentPageViewControllerDelegate {
	func commentPageViewControllerDidFinish(_ cpVC: CommentPageViewController) {
		navDelegate?.commentNavControllerDidFinish(self)
	}
}
