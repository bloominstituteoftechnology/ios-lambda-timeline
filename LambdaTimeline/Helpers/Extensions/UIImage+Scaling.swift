//
//  UIImage+Scaling.swift
//  iOS8 Photo Filter
//
//  Created by Michael Redig on 9/30/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//
//swiftlint:disable conditional_returns_on_newline

import UIKit
import ImageIO

extension UIImage {

    /// Resize the image to a max dimension from size parameter
    func imageByScaling(toSize size: CGSize) -> UIImage? {

        guard let data = flattened.pngData(),
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]

        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary).flatMap { UIImage(cgImage: $0) }
    }

    /// Renders the image if the pixel data was rotated due to orientation of camera
    var flattened: UIImage {
        if imageOrientation == .up { return self }
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { _ in
            draw(at: .zero)
        }
    }
}
