//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import MapKit
import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var postController: PostController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        fetchImagePosts()
        fetchVideoPosts()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostView")
    }
    
    private func fetchImagePosts() {
        postController.observePosts { error in
            if let error = error { print("Error: \(error)") }
            DispatchQueue.main.async { self.mapView.addAnnotations(self.postController.posts) }
        }
    }
    
    private func fetchVideoPosts() {
        postController.observeVideoPosts { error in
            if let error = error { print("Error: \(error)") }
            DispatchQueue.main.async { self.mapView.addAnnotations(self.postController.videoPosts) }
        }
    }
}

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
