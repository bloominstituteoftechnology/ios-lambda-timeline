//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Bobby Keffury on 1/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    //MARK: - Properties
    
    private var userTrackingButton: MKUserTrackingButton!
    private let locationManager = CLLocationManager()
    var annotations: [PostAnnotation] = []
    
    private let annotationReuseIdentifier = "PostAnnotation"
    
    //MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        setupSubviews()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationReuseIdentifier)
    }
    
    //MARK: - Methods
    
    private func setupSubviews() {
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(userTrackingButton)
        
        userTrackingButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20.0).isActive = true
        userTrackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30.0).isActive = true
    }
    
    func fetchAnnotations() {
        
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        fetchAnnotations()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let post = annotation as? PostAnnotation else { return nil }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationReuseIdentifier, for: post) as? MKMarkerAnnotationView else {
            fatalError("Missing registered map annotation view.")
        }
        
        return annotationView
    }
}
