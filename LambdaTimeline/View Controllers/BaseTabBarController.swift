//
//  SourcTC.swift
//  LambdaTimeline
//
//  Created by Nick Nguyen on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class BaseTabBarController: UITabBarController, UITabBarControllerDelegate {

  let postController = PostController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item:")
        
    }

    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Hello")
        if let navController = viewController as? UINavigationController {
            if let mapVC = navController.viewControllers.first as? MapViewController {
                  mapVC.postController = postController
            }
        }
//        if let mapVC = viewController as? MapViewController {
//           mapVC.postController = postController
//            print(mapVC.navigationItem.title)  }
//        else if let postCollectionVC = viewController as? PostsCollectionViewController {
//            postCollectionVC.postController = postController
//        }
    }
  
}
