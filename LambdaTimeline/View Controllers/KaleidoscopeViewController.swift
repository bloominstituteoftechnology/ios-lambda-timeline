//
//  KaleidoscopeViewController.swift
//  LambdaTimeline
//
//  Created by Lisa Sampson on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class KaleidoscopeViewController: FilterControlsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        filter = CIFilter(name: "CIKaleidoscope")
        
        //configureSlider(countSlider, from: filter.attributes["Count"])
        //configureSlider(centerSlider, from: filter.attributes[kCIInputCenterKey])
        configureSlider(angleSlider, from: filter.attributes[kCIInputAngleKey])

    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        //filter.setValue(countSlider.value, forKey: "Count")
        //filter.setValue(centerSlider.value, forKey: kCIInputCenterKey)
        filter.setValue(angleSlider.value, forKey: kCIInputAngleKey)
        
        delegate?.sliderChangedValues()
    }
    
//    @IBOutlet weak var countSlider: UISlider!
//    @IBOutlet weak var centerSlider: UISlider!
    @IBOutlet weak var angleSlider: UISlider!
}
