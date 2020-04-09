//
//  GeoTagViewController.swift
//  GeoTags
//
//  Created by Chris Gonzales on 4/9/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GeoTagViewController: UIViewController {
    
    var geoTag: Tag?{
        didSet{
            
        }
    }
    var locationManager: CLLocationManager?
    
    @IBOutlet var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: "GeoTagView")
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }

}

extension GeoTagViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let geoTag = annotation as? Tag,
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "GeoTagView", for: geoTag) as? MKMarkerAnnotationView else {
           fatalError()
        }
      
        self.mapView.addAnnotation(geoTag)
        let detailView = GeoTagDetailView()
        detailView.geoTag = geoTag
        return nil
    }
}

extension GeoTagViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                 if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                     guard let locationManager = locationManager else { return }
                    let location: CLLocation = locations[0]
                     print("\(location)")
                    let lat = location.coordinate.latitude
                    let long = location.coordinate.longitude
                    geoTag = Tag(longitude: long,
                                 latitude: lat)
                    
        }
             
    }
}
