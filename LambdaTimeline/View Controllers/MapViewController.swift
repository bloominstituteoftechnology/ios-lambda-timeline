//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Isaac Lyons on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var postController: PostController!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostView")
        
        loadPosts()
    }
    
    private func loadPosts() {
        let postAnnotations = postController.posts.compactMap({ PostAnnotation(post: $0) })
        
        mapView.addAnnotations(postAnnotations)
    }

}

extension MapViewController: MKMapViewDelegate {}
