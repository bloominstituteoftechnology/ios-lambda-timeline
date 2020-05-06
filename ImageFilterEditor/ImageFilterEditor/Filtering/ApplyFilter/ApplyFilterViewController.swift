//
//  ApplyFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/4/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit
import CoreImage

class ApplyFilterViewController: UIViewController {

    // MARK: - Public Properties
    
    var filter: ImageFilter?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - IBActions

    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sliderControlsVC = segue.destination as? SliderControlsViewController,
            let filter = filter {
            sliderControlsVC.filterControls = filter.controls
            sliderControlsVC.delegate = self
        }
    }
}

extension ApplyFilterViewController: ImageFilterLinearControlDelegate {
    func filterControl(_ control: ImageFilterLinearControl, didChangeValueTo value: Float) {
        guard let filter = filter else { return }
        filter.coreImageFilter.setValue(value, forKey: control.filterParameterKey)
    }
}
