//
//  VideoMapViewController.swift
//  Video
//
//  Created by Wyatt Harrell on 5/7/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import MapKit

class VideoMapViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "VideoView")

        self.mapView.addAnnotations(videoController.videos)
        guard let video = videoController.videos.first else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: video.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
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

extension VideoMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let video = annotation as? Video else {
            fatalError("Only videos are supported")
        }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "VideoView", for: annotation) as? MKMarkerAnnotationView else { fatalError("Missing a register view") }
        
        //annotationView.canShowCallout = true
        //let detailView = VideoDetailView()
        //detailView.quake = quake
        //annotationView.detailCalloutAccessoryView = detailView
        
        return annotationView
    }
}
