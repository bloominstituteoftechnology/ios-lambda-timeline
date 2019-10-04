//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var postController: PostController!
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.observePosts { (_) in
           
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var postAnnotations: [PostAnnotation] = []
        for post in self.postController.posts {
            if post.latitude != nil && post.longitude != nil {
                postAnnotations.append(PostAnnotation(post: post))
            }
        }
        DispatchQueue.main.async {
            
            if let firstPostAnnotation = postAnnotations.first {
                let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                let region = MKCoordinateRegion(center: firstPostAnnotation.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
            }
            self.mapView.addAnnotations(postAnnotations)
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
