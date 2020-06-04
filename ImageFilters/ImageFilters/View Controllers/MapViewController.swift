//
//  MapViewController.swift
//  ImageFilters
//
//  Created by Mark Poggi on 6/4/20.
//  Copyright © 2020 Mark Poggi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // MARK: - Properties

    let locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?

    // MARK: - Outlets

    @IBOutlet var mapView: MKMapView!

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "MapCell")
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        if let userLocation = mapView.userLocation.location?.coordinate {
            mapView.setCenter(userLocation, animated: true)
        }




    }

    // MARK: - Methods

    func addAnnotation() {
        let myMarker = MKPointAnnotation()
        myMarker.title = "Test"
        mapView.addAnnotation(myMarker)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        mapView.mapType = MKMapType.standard
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        annotation.title = "test"
        mapView.addAnnotation(annotation)
        coordinate = annotation.coordinate
    }
}
