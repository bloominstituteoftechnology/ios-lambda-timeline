//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Karen Rodriguez on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var postController: PostController?

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostView")

        if let posts = postController?.posts {
            mapView.addAnnotations(posts)
        }
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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let post = annotation as? Post else {
            fatalError("Currently only supporting Posts")
        }

        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostView", for: post) as? MKMarkerAnnotationView else {
            fatalError("Missing a registered map annotation")
        }

        annotationView.glyphImage = UIImage(named: "􀉛")

        annotationView.canShowCallout = true
        let detailView = PostDetailView()
        detailView.post = post
        annotationView.detailCalloutAccessoryView = detailView
        
        return annotationView
    }
}
