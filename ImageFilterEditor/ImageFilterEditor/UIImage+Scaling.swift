//
//  UIImage+Scaling.swift
//  ImageFilterEditor
//
//  Created by Gerardo Hernandez on 5/6/20.
//  Copyright © 2020 Gerardo Hernandez. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Resize the image to a max dimension from size parameter
    func imageByScaling(toSize size: CGSize) -> UIImage? {
        
        guard size.width > 0 && size.height > 0 else { return nil }
        
        let originalAspectiRatio = self.size.width/self.size.height
        var correctedSize = size
        
        if correctedSize.width > correctedSize.width*originalAspectiRatio {
            correctedSize.width = correctedSize.width*originalAspectiRatio
        } else {
            correctedSize.height = correctedSize.height/originalAspectiRatio
        }
        
        return UIGraphicsImageRenderer(size: correctedSize, format: imageRendererFormat).image { context in
            draw(in: CGRect(origin: .zero, size: correctedSize))
        }
    }
    
    /// Renders the image if the pixel data was rotated due to orientation of camera

    var flattened: UIImage {
        if imageOrientation == .up { return self }
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { context in
            draw(at: .zero)
        }
    }
}
