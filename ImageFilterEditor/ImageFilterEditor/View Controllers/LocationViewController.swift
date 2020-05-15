//
//  LocationViewController.swift
//  ImageFilterEditor
//
//  Created by denis cedeno on 5/14/20.
//  Copyright © 2020 DenCedeno Co. All rights reserved.
//

import UIKit
import MapKit

extension String {
    static let annotationReuseIdentifier = "PhotoAnnotationView"
}

class LocationViewController: UIViewController {
    

    @IBOutlet var mapView: MKMapView!
    
    private var userTrackingButton: MKUserTrackingButton!
    private let locationManager = CLLocationManager()

    
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
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: .annotationReuseIdentifier)
        
        fetchLocation()
    }
    
    func fetchLocation() {

    }
}
