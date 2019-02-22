//
//  PostMapViewController.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class PostMapViewController: UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    var postController: PostController?
    private var postAnnotations = Array<PostAnnotation>() {
        didSet {
            let oldPosts = Set(oldValue)
            let newPosts = Set(postAnnotations)
            
            //
            let addedPosts = newPosts.subtracting(oldPosts)
            let removedPosts = oldPosts.subtracting(newPosts)
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(Array(removedPosts))
                self.mapView.addAnnotations(Array(addedPosts))
            }
            
        }
        
        
    }
    
    // MARK: - Private Methods
    private func fetchPosts() {
        let currentArea = mapView.visibleMapRect
        let currentRegion = CoordinateRegion(mapRect: currentArea)
        
        // TODO: Implement fetch methods on postController
        postController.fetchPostAnnotations { (postAnnotations, error) in
            if let error = error {
                NSLog("Error fetching quakes: \(error)")
            }
            self.postAnnotations = posts ?? []
        }
    }
    
    // MARK: - MapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let postAnnontation = annotation as? PostAnnotation else { return nil }
        let postView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostAnnotationView", for: postAnnontation) as! MKMarkerAnnotationView
        
        postView.glyphImage = UIImage(named: "cellular_network")
        postView.glyphTintColor = .white
        
        postView.canShowCallout = true
        let detailView = QuakeDetailView()
        detailView.post = postAnnontation.post
        postView.detailCalloutAccessoryView = detailView
        
        return postView
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        fetchPosts()
    }
    
     
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
