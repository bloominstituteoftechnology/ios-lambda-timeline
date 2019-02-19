//
//  NoiseReductionViewController.swift
//  LambdaTimeline
//
//  Created by Lisa Sampson on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class NoiseReductionViewController: FilterControlsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        filter = CIFilter(name: "CINoiseReduction")
        
        //configureSlider(noiseLevelSlider, from: filter.attributes[])
        configureSlider(sharpnessSlider, from: filter.attributes[kCIInputSharpnessKey])

    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        //filter.setValue(noiseLevelSlider.value, forKey: )
        filter.setValue(sharpnessSlider.value, forKey: kCIInputSharpnessKey)
        
        delegate?.sliderChangedValues()
    }
    
    @IBOutlet weak var noiseLevelSlider: UISlider!
    @IBOutlet weak var sharpnessSlider: UISlider!
}
