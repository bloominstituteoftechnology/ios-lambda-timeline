//
//  PlzFinishViewController.swift
//  LambdaTimeline
//
//  Created by Karen Rodriguez on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class PlzFinishViewController: UITabBarController {


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        vaccine()
    }

    private func vaccine() {
        let postController = PostController()
        // Get it? Cause dependency INJECTION
        guard let posts = self.viewControllers![0] as? PostsCollectionViewController,
            let map = self.viewControllers![1] as? MapViewController else { fatalError("Wrong ones dumbass") }

        posts.postController = postController
        map.postController = postController
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
