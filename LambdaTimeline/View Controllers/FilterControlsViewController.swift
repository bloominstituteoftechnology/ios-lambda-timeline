//
//  FilterControlsViewController.swift
//  LambdaTimeline
//
//  Created by Lisa Sampson on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreImage

protocol FilterControlsViewControllerDelegate: class {
    func sliderChangedValues()
}

class FilterControlsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var filter: CIFilter!
    weak var delegate: FilterControlsViewControllerDelegate?
    
    func configureSlider(_ slider: UISlider, from attributes: Any?) {
        
        let attrs = attributes as? [String: Any] ?? [:]
        
        if let min = attrs[kCIAttributeSliderMin] as? Float,
            let max = attrs[kCIAttributeSliderMax] as? Float,
            let value = attrs[kCIAttributeDefault] as? Float {
            
            slider.minimumValue = min
            slider.maximumValue = max
            slider.value = value
        } else {
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.value = 0.5
        }
    }

}
