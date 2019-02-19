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

    }
    
    @IBOutlet weak var countSlider: UISlider!
    @IBOutlet weak var centerSlider: UISlider!
    @IBOutlet weak var angleSlider: UISlider!
}
