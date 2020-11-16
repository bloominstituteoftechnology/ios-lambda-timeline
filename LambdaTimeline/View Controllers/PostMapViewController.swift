//
//  PostMapViewController.swift
//  LambdaTimeline
//
//  Created by Kenneth Jones on 11/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

enum ReuseIdentifier {
    static let postAnnotation = "PostAnnotationView"
}

class PostMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var userTrackingButton: MKUserTrackingButton!
    
    private let locationManager = CLLocationManager()
    
    var postController: PostController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTrackingButton)
        
        NSLayoutConstraint.activate([
            userTrackingButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            mapView.bottomAnchor.constraint(equalTo: userTrackingButton.bottomAnchor, constant: 20)
        ])
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReuseIdentifier.postAnnotation)
        
        mapView.addAnnotations(postController.mapPosts)
    }
}
