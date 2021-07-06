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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPosts()
    }
    
    private func loadPosts() {
        let postAnnotations = postController.posts.compactMap({ PostAnnotation(post: $0) })
        
        for postAnnotation in postAnnotations {
            if !mapView.annotations.contains(where: { $0.coordinate.latitude == postAnnotation.coordinate.latitude
                && $0.coordinate.longitude == postAnnotation.coordinate.longitude
                && $0.title == postAnnotation.title
                && $0.subtitle == postAnnotation.subtitle }) {
                mapView.addAnnotation(postAnnotation)
            }
        }
        
        print(mapView.annotations.count)
    }

}

extension MapViewController: MKMapViewDelegate {}
