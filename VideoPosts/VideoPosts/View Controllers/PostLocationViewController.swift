//
//  PostLocationViewController.swift
//  VideoPosts
//
//  Created by David Wright on 5/14/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
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

extension PostLocationViewController: MKMapViewDelegate {
    
}
