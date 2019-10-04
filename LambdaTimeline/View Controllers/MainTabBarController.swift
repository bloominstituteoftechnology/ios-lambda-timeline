//
//  MainTabBarController.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    let postController = PostController()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.viewControllers)
        guard let navController = self.viewControllers?[0] as? MainNavigationController, let mapVC = self.viewControllers?[1] as? MapViewController else { return }
        navController.postController = postController
        mapVC.postController = postController
        
    }
}
