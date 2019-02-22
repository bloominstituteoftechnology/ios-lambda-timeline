//
//  PostsTabBarController.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class PostsTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navController = self.viewControllers?[0] as! UINavigationController
        let postMapViewController = self.viewControllers?[1] as! PostMapViewController
        
        postMapViewController.postController = postController
        
        
    }
    private var postController: PostController = PostController()

}
