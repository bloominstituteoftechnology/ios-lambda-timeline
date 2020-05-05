//
//  ImageFilter.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit
import CoreImage

protocol ImageFilter {
    var name: String { get }
    var icon: UIImage { get }
    var controls: [ImageFilterLinearControl] { get }
    var coreImageFilter: CIFilter { get }
}

struct VignetteFilter: ImageFilter {
    let name = "Vignette"
    
    let icon = UIImage(systemName: "person.circle.fill")!
    
    let controls = [
        ImageFilterLinearControl(minValue: 0, maxValue: 1, defaultValue: 0, label: "Strength", filterParameterKey: kCIInputIntensityKey),
        ImageFilterLinearControl(minValue: 1, maxValue: 10, defaultValue: 1, label: "Radius", filterParameterKey: kCIInputRadiusKey),
    ]
    
    let coreImageFilter: CIFilter = CIFilter.vignette()
}
