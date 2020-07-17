//
//  LocationViewController.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/16/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {
    // MARK: - IBOutlets
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

// MARK: - Extension
extension LocationViewController: MKMapViewDelegate {
    
}
