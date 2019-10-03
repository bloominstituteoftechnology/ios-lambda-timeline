//
//  GeoTagViewController.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class GeoTagViewController: UIViewController, PostControllerAccessor {
	@IBOutlet private var mapView: MKMapView!

	var postController: PostController!

    override func viewDidLoad() {
        super.viewDidLoad()

		postController.observePosts { error in
			DispatchQueue.main.async {
				self.mapView.removeAnnotations(self.mapView.annotations)
				self.mapView.addAnnotations(self.postController.geoPosts)
			}
		}
    }


}
