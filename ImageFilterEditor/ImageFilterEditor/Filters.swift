//
//  Filters.swift
//  ImageFilterEditor
//
//  Created by Clayton Watkins on 9/2/20.
//  Copyright © 2020 Clayton Watkins. All rights reserved.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins


class Filters {
    
    // MARK: - Properties
    let blurFilter = CIFilter.gaussianBlur()
    let falseColorFilter = CIFilter.falseColor()
    let vignetteFilter = CIFilter.vignette()
    let whitePointFilter = CIFilter.whitePointAdjust()
    let monoChromaticFilter = CIFilter.photoEffectMono()
    
    
    
    
}
