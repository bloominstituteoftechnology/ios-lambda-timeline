//
//  MapViewController.swift
//  VideoPosts
//
//  Created by Tobi Kuyoro on 08/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var recordingController: RecordingController?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocation()
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "RecordView")

        guard let recordings = recordingController?.recordings else { return }
        mapView.addAnnotations(recordings)
    }

    // MARK: - Location Methods

    func configureLocation() {
        locationManager.delegate = self

        let status = CLLocationManager.authorizationStatus()

        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(using: locationManager)
        }
    }

    func beginLocationUpdates(using locationManager: CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(using: manager)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "RecordView", for: annotation) as? MKMarkerAnnotationView else {
            fatalError("Missing a registered view")
        }

        annotationView.annotation = annotation
        annotationView.displayPriority = .required
        annotationView.canShowCallout = true
        return annotationView
    }
}
