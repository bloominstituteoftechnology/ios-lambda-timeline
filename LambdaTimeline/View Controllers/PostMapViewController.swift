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

class PostMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var userTrackingButton: MKUserTrackingButton!
    
    private let locationManager = CLLocationManager()
    
    var posts: [PostAnnotation] = [] {
        didSet {
            let oldPosts = Set(oldValue)
            let newPosts = Set(posts)
            
            let addedPosts = newPosts.subtracting(oldPosts)
            let removedPosts = oldPosts.subtracting(newPosts)
            
            mapView.removeAnnotations(Array(removedPosts))
            mapView.addAnnotations(Array(addedPosts))
        }
    }
    
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
    }
}

extension PostMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let post = annotation as? PostAnnotation else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifier.postAnnotation, for: post) as! MKMarkerAnnotationView
        
        annotationView.glyphImage = #imageLiteral(resourceName: "QuakeIcon")
        
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}
