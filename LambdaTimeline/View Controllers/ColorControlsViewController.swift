//
//  ColorControlsViewController.swift
//  LambdaTimeline
//
//  Created by Lisa Sampson on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class ColorControlsViewController: FilterControlsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter = CIFilter(name: "CIColorControls")
        
        configureSlider(brightnessSlider, from: filter.attributes[kCIInputBrightnessKey])
        configureSlider(contrastSlider, from: filter.attributes[kCIInputContrastKey])
        configureSlider(saturationSlider, from: filter.attributes[kCIInputSaturationKey])

    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        filter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
        filter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)
        filter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)
        
        delegate?.sliderChangedValues()
    }
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
}
