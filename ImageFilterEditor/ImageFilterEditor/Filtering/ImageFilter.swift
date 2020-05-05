//
//  ImageFilter.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

protocol ImageFilter {
    var name: String { get }
    var icon: UIImage { get }
    var filterControls: [ImageFilterControl] { get }
    var coreImageFilter: CIFilter { get }
}

struct VignetteFilter: ImageFilter {
    var name = "Vignette"
    
    var icon = UIImage(systemName: "person.circle.fill")!
    
    var filterControls: [ImageFilterControl] {
        [
            ImageFilterControl(minValue: 0, maxValue: 1, defaultValue: 0.5, label: "Strength"),
        ]
    }
    
    var coreImageFilter: CIFilter {
        CIFilter.vignette()
    }
}
