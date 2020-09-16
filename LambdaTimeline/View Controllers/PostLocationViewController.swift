//
//  PostLocationViewController.swift
//  LambdaTimeline
//
//  Created by Clayton Watkins on 9/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    var location: CLLocationCoordinate2D?
    var postTitle: String?
    var postAuthor: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = .standard
//        if let userLocation = location {
//            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
//            mapView.setRegion(viewRegion, animated: false)
//        }
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: .annotationReuseIdentifier)
        mapView.delegate = self
        setPinUsingMKPointAnnotation(location: location!)
    }
    
    func setPinUsingMKPointAnnotation(location: CLLocationCoordinate2D){
       let annotation = MKPointAnnotation()
       annotation.coordinate = location
       annotation.title = postTitle
       annotation.subtitle = postAuthor
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
       mapView.setRegion(coordinateRegion, animated: true)
       mapView.addAnnotation(annotation)
    }
}

extension String {
    static let annotationReuseIdentifier = "PostLocationView"
}

extension PostLocationViewController: MKMapViewDelegate {
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //        guard let post = annotation as? Post else { return nil }
    //        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: .annotationReuseIdentifier, for: post)
    //
    //        return annotationView
    //    }
    
    
}
