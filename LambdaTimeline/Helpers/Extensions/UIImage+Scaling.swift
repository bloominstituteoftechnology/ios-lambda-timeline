//
//  UIImage+Scaling.swift
//  LambdaTimeline
//
//  Created by Jerry haaser on 1/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

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
