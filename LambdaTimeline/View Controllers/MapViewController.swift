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

    // FIXME: Post object goes here

    // MARK: - Actions


    // MARK: - Outlets

    @IBOutlet var mapView: MKMapView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        // MKMarkerAnnotationView like a table view cell
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostView")

//        print("Total posts: \(posts.count)")
//
//        for post in posts {
//
//            DispatchQueue.main.async {
//                self.mapView.addAnnotations(posts)
//
//                // FIXME: Only 1? What about the rest?
//                guard let posts = posts.first else { return }
//
//                let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
//                let region = MKCoordinateRegion(center: posts.coordinate, span: span)
//                self.mapView.setRegion(region, animated: true)
//            }
//        }
    }

    // MARK: - Private

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let post = annotation as? Post else {
//            fatalError("Only posts are supported")
//        }

        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostView", for: annotation) as? MKMarkerAnnotationView else {
            fatalError("Missing a registered view")
        }

//        annotationView.canShowCallout = true
//        let detailView = QuakeDetailView()
//        detailView.quake = quake
//        annotationView.detailCalloutAccessoryView = detailView

        return annotationView
    }
}
