//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Nick Nguyen on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, UITabBarControllerDelegate, MKMapViewDelegate {

    var postController : PostController?
    
    @IBOutlet weak var mapTypeSegmentController: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
         mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Post")
        mapView.delegate = self
        if let post = postController {
            post.observePosts { (_) in
                self.mapView.addAnnotations(post.posts)
                let coordinateSpan = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                let region = MKCoordinateRegion(center: post.posts.first!.coordinate, span: coordinateSpan)
                
                self.mapView.setRegion(region, animated: true)
                
            }
        }
     
      
    }

    @IBAction func mapTypeSegmentControlSwitch(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                mapView.mapType = .standard
            case 2:
            mapView.mapType = .satelliteFlyover
                            
                          let camera = MKMapCamera(lookingAtCenter: (postController?.posts.first!.coordinate)!, fromDistance: 300, pitch: 40, heading: 0)
                                   mapView.camera = camera
                                   mapView.isRotateEnabled = true
                     
            default:
                mapView.mapType = .satellite
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
          let identifier = "Post"
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotation is MKUserLocation {    return nil    }
             
        annotationView?.glyphImage = UIImage(systemName: "heart")
        annotationView?.glyphTintColor = .yellow
          annotationView?.accessibilityActivate()
        annotationView?.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)

        annotationView?.rightCalloutAccessoryView = button
        return annotationView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
          // Open Apple map
          let coordinate = CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude,
                                                      mapView.centerCoordinate.longitude)
          
          let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate,
                                                         addressDictionary:nil))
          
          if let annotation = view.annotation, let name = annotation.title {
              mapItem.name = "\(name ?? "...")"
          }
          
          mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])

       }
}

