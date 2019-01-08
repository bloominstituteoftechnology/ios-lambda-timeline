//
//  UIImage+Scaling.swift
//  PhotoFilter
//
//  Created by Andrew R Madsen on 10/15/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {
    func imageByScaling(toSize size: CGSize) -> UIImage? {
        guard let data = pngData(),
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) / 2.0,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        
        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary).flatMap { UIImage(cgImage: $0) }
    }
}
