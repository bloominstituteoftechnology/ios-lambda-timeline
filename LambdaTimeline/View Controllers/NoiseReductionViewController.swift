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

    }
    
    @IBOutlet weak var noiseLevelSlider: UISlider!
    @IBOutlet weak var sharpnessSlider: UISlider!
}
