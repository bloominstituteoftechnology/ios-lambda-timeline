//
//  ComicEffectViewController.swift
//  LambdaTimeline
//
//  Created by Lisa Sampson on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreImage

class ComicEffectViewController: FilterControlsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter = CIFilter(name: "CIComicEffect")
    }
    
    
}
