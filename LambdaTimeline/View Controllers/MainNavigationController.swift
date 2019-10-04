//
//  MainNavigationController.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import Foundation
class MainNavigationController: UINavigationController {
    var postController: PostController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let boardVC = self.viewControllers[0] as? PostsCollectionViewController else { return }
        boardVC.postController = postController
    }
}
