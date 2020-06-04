//
//  MapViewController.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/4/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var posts: [Post] = []

    
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostView")
        
        print("Total posts: \(posts.count)")

        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.posts)

            // Center the map based on the first element
            guard let post = self.posts.first else { return }

            let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
            let region = MKCoordinateRegion(center: post.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    

   

}
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let post = annotation as? Post else {
            fatalError("Only image objects are supported right now")
        }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostView", for: post) as? MKMarkerAnnotationView else {
            fatalError("Missing a registered map annotation view")
        }
        
        annotationView.glyphImage = nil
        annotationView.canShowCallout = true
        let detailView = MapDetailView()
        detailView.post = post
        annotationView.detailCalloutAccessoryView = detailView
        
        return annotationView
    }
}
