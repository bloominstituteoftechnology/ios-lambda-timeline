//
//  MapVC.swift
//  LambdaTimeline
//
//  Created by Cora Jacobson on 11/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

enum ReuseIdentifier {
    static let postAnnotation = "AnnotationView"
}

class MapVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private var mapView: MKMapView!
    
    // MARK: - Properties
    
    var span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    var pins: [MKAnnotation] = [] {
        didSet {
            mapView.removeAnnotations(pins)
            mapView.addAnnotations(pins)
        }
    }
    var postController: PostController!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBC = self.tabBarController as! TabBarController
        postController = tabBC.postController
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReuseIdentifier.postAnnotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMap()
    }
    
    // MARK: - Private Functions
    
    private func setUpMap() {
        createPins()
        LocationController.shared.getUserLocation()
        let userLocation = LocationController.shared.userLocation
        if let userLocation = userLocation {
            let coordinateRegion = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(coordinateRegion, animated: true)
            mapView.showsUserLocation = true
        }
    }
    
    private func createPins() {
        for post in postController.posts {
            guard let geotag = post.geotag else { continue }
            var image: UIImage?
            switch post.mediaType {
            case .image(let stillImage):
                image = stillImage
            case .video(let videoURL):
                postController.imageFromVideo(url: videoURL, at: 0) { videoFrame in
                    image = videoFrame
                }
            }
            let pin = Annotation(coordinate: geotag, title: post.title, subtitle: post.author, date: post.timestamp, image: image)
            pins.append(pin)
        }
    }

}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pin = annotation as? Annotation else { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifier.postAnnotation, for: pin) as! MKMarkerAnnotationView
        
        annotationView.markerTintColor = .systemPurple
        annotationView.glyphText = pin.title
        let detailView = AnnotationDetailView()
        detailView.pin = pin
        annotationView.detailCalloutAccessoryView = detailView
        annotationView.canShowCallout = true
        
        return annotationView
    }
}
