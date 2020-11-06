//
//  PostLocationViewController.swift
//  LambdaTimeline
//
//  Created by Rob Vance on 11/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocationCoordinate2D?
    var postTitle: String?
    var postAuthor: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = .standard
        mapView.register(MKAnnotation.self, forAnnotationViewWithReuseIdentifier: .reuseIdentifier)
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    func setPinWithMKPointAnnotation(location: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = postTitle
        annotation.subtitle = postAuthor
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 150, longitudinalMeters: 150)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
}

extension String {
    static let reuseIdentifier = "PostLocationView"
}
