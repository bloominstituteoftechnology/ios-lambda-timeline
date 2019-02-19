//
//  MotionBlurViewController.swift
//  LambdaTimeline
//
//  Created by Lisa Sampson on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MotionBlurViewController: FilterControlsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter = CIFilter(name: "CIMotionBlur")
        
        configureSlider(radiusSlider, from: filter.attributes[kCIInputRadiusKey])
        configureSlider(angleSlider, from: filter.attributes[kCIInputAngleKey])

    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        filter.setValue(radiusSlider.value, forKey: kCIInputRadiusKey)
        filter.setValue(angleSlider.value, forKey: kCIInputAngleKey)
        
        delegate?.sliderChangedValues()
    }
    
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var angleSlider: UISlider!
}
