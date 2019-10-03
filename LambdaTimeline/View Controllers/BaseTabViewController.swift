//
//  BaseTabViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class BaseTabViewController: UITabBarController {
	let postController = PostController()

    override func viewDidLoad() {
        super.viewDidLoad()

		for vc in viewControllers ?? [] {
			guard let postAccessor = vc as? PostControllerAccessor else { continue }
			postAccessor.postController = postController
		}
    }
}
