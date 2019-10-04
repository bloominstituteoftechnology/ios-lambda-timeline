//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    var postController: PostController!
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.observePosts { (_) in
            DispatchQueue.main.async {
                
            }
        }
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
