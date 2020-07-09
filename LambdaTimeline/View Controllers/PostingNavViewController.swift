//
//  PostingNavViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class PostingNavViewController: UINavigationController, PostControllerAccessor {

	var postController: PostController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		for child in children {
			guard let postAccessor = child as? PostControllerAccessor else { continue }
			postAccessor.postController = postController
		}
    }
}
