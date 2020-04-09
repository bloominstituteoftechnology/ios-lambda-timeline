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

class MapViewController: UIViewController, UITabBarControllerDelegate {

    var postController : PostController?
    
    @IBOutlet weak var mapTypeSegmentController: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if let post = postController {
            
        }
    
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(viewController)
    }
    @IBAction func mapTypeSegmentControlSwitch(_ sender: UISegmentedControl) {
        
    }
    
}
