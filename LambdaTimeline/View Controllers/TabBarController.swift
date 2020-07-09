//
//  TabBarController.swift
//  LambdaTimeline
//
//  Created by Vici Shaweddy on 1/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    private let postController = PostController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for vc in self.viewControllers ?? [] {
            if let nc = vc as? UINavigationController, let vc = nc.topViewController as? PostsCollectionViewController {
                vc.postController = self.postController
            }
            if let vc = vc as? MapViewController {
                vc.postController = self.postController
            }
        }
    }
}
