//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-16.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var postController: PostController!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let tabBarController = self.tabBarController as? TimelineTabBarController {
            self.postController = tabBarController.postController
        }
    }
}
