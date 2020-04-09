//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Enrique Gongora on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var MKMapView: MKMapView!
    
    // MARK: - Variables
    var postController: PostController!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Functions
    private func setupMapView() {
        MKMapView.delegate = self
        MKMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostView")
    }
    
    private func fetchImagePosts() {
        postController.observePosts { error in
            if let error = error { print("Error: \(error)") }
            DispatchQueue.main.async { self.MKMapView.addAnnotations(self.postController.posts) }
        }
    }
    
    private func fetchVideoPosts() {
        postController.observeVideoPosts { error in
            if let error = error { print("Error: \(error)") }
            DispatchQueue.main.async { self.mapView.addAnnotations(self.postController.videoPosts) }
        }
    }
}

// MARK: - Extensions
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? Post {
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostView") as? MKMarkerAnnotationView else { return nil }
            annotationView.glyphImage = UIImage(systemName: "camera")
            annotationView.glyphTintColor = .black
            annotationView.markerTintColor = .systemBlue
            return annotationView
        } else if let _ = annotation as? VideoPost {
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostView") as? MKMarkerAnnotationView else { return nil }
            annotationView.glyphImage = UIImage(systemName: "video")
            annotationView.glyphTintColor = .black
            annotationView.markerTintColor = .systemRed
            return annotationView
        } else {
            fatalError("Annotation object not supported")
        }
    }
}
