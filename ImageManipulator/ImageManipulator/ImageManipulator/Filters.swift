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

extension PhotoFilterViewController {
    func filter(_ image: UIImage, for name: String) -> CIFilter? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        switch name  {
            
        case "CIThermal":
            let filter1 = CIFilter(name: "CIThermal")
            filter1?.setValue(ciImage, forKey: kCIInputImageKey)
            return filter1
        
        case "CIDiscBlur":
            let filter2 = CIFilter(name: "CIDiscBlur")
            filter2?.setValue(ciImage, forKey: kCIInputImageKey)
            filter2?.setValue(8, forKey: kCIAttributeTypeDistance)
            return filter2
        case "CIBloom":
            let filter3 = CIFilter(name: "CIBloom")
            filter3?.setValue(ciImage, forKey: kCIInputImageKey)
            filter3?.setValue(10, forKey: kCIAttributeTypeDistance)
            filter3?.setValue(0.5, forKey: kCIAttributeTypeScalar)
            return filter3
        

}
}
