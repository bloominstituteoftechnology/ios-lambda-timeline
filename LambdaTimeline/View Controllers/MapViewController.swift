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
        mapView.delegate = self
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: "PostAnnotationView")
        setUpTags()
    }

    func setUpTags() {
        let annotations = postController.posts.compactMap { $0.mapAnnotation }
        mapView.addAnnotations(annotations)

        guard let firstAnnotation = annotations.first else { return }
        mapView.setRegion(
            MKCoordinateRegion(
                center: firstAnnotation.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 2,
                    longitudeDelta: 2)),
            animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard
            let postAnnotation = annotation as? PostAnnotation,
            let annotationView = mapView
                .dequeueReusableAnnotationView(withIdentifier: "PostAnnotationView")
                as? MKMarkerAnnotationView
            else { return nil }

        annotationView.canShowCallout = true
        let detailView = PostAnnotationView()
        detailView.post = postAnnotation.post
        annotationView.detailCalloutAccessoryView = detailView

        return annotationView
    }
}
