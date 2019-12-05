//
//  TabBarController.swift
//  LambdaTimeline
//
//  Created by Isaac Lyons on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let postController = PostController()

    override func viewDidLoad() {
        super.viewDidLoad()

        for viewController in viewControllers ?? [] {
            if let navigationVC = viewController as? UINavigationController {
                for viewController in navigationVC.viewControllers {
                    if let postsVC = viewController as? PostsCollectionViewController {
                        postsVC.postController = postController
                    }
                }
            } else if let mapVC = viewController as? MapViewController {
                mapVC.postController = postController
            }
        }
    }

}
