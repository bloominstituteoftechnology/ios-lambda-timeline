//
//  PhotoMapViewController.swift
//  ImageFilterEditor
//
//  Created by denis cedeno on 5/14/20.
//  Copyright © 2020 DenCedeno Co. All rights reserved.
//
import UIKit
import MapKit
import CoreData

extension String {
    static let annotationReuseIdentifier = "PhotoAnnotationView"
}

class PhotoMapViewController: UIViewController {
    
    var photos: [FilteredImage] = []
    var photo: FilteredImage?
    private let photoController = FilteredImageController()

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
        
        fetchPhotoLocation(photos)
    }

    
    func fetchPhotoLocation(_ photos: [FilteredImage]) {
      for photo in photos {
        let annotations = MKPointAnnotation()
        annotations.title = photo.comments
        annotations.subtitle = "\(String(describing: photo.date))"
        annotations.coordinate = CLLocationCoordinate2D(latitude:
          photo.lattitude, longitude: photo.longitude)
        mapView.addAnnotation(annotations)
      }
    }
}
