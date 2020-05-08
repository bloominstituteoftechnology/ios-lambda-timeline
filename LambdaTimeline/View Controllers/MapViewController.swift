//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Mark Gerrior on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
// NOTE: Don't forget Project > Target > General > Frameworks > add MapKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - Properites

    var posts: [Post] = []

    // MARK: - Actions


    // MARK: - Outlets

    @IBOutlet var mapView: MKMapView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        // MKMarkerAnnotationView like a table view cell
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostView")

        print("Total posts: \(posts.count)")

        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.posts)

            // Center the map based on the first element
            guard let post = self.posts.first else { return }

            let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
            let region = MKCoordinateRegion(center: post.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }

    // MARK: - Private

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let post = annotation as? Post else {
            fatalError("Only posts are supported")
        }

        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostView", for: annotation) as? MKMarkerAnnotationView else {
            fatalError("Missing a registered view")
        }

        annotationView.canShowCallout = true
        let detailView = MapDetailView()
        detailView.post = post
        annotationView.detailCalloutAccessoryView = detailView

        return annotationView
    }
}
