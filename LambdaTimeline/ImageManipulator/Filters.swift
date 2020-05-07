//
//  Filters.swift
//  ImageManipulator
//
//  Created by Lambda_School_Loaner_268 on 5/4/20.
//  Copyright © 2020 Lambda. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

struct Filters {
    func chooseFilter(for filterName: String) -> CIFilter? {
            
            switch filterName  {
                
            case "CIThermal":
                let filter1 = CIFilter(name: "CIThermal")
                return filter1
            
            case "CIDiscBlur":
                let filter2 = CIFilter(name: "CIDiscBlur")
                
                return filter2
            case "CIBloom":
                let filter3 = CIFilter(name: "CIBloom")
               
                return filter3
            case "CICrystallize":
                let filter4 = CIFilter(name: "CICrystallize")
                
                filter4?.setValue(20, forKey: kCIAttributeTypeDistance)
                filter4?.setValue([150, 150], forKey: kCIAttributeTypePosition)
                return filter4
            case "CIPixelate":
                let filter5 = CIFilter(name: "CIPixelate")
              
                filter5?.setValue([150, 150], forKey: kCIAttributeTypePosition)
                filter5?.setValue(8.00, forKey: kCIAttributeTypeDistance)
                return filter5
            default:
                let filter6 = CIFilter(name: "CIColorControls")
              
                filter6?.setValue(0, forKey: kCIInputSaturationKey) // k = constant in Objective-C
                filter6?.setValue(0, forKey: kCIInputBrightnessKey)
                filter6?.setValue(0, forKey: kCIInputContrastKey)
                return filter6
                
            }

}
}
