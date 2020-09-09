//
//  CIImage+JPEG.swift
//  LambdaTimeline
//
//  Created by Morgan Smith on 9/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreImage
import Photos
extension CIImage {

    func saveJPEG(_ name:String, inDirectoryURL:URL? = nil, quality:CGFloat = 1.0) -> String? {

        var destinationURL = inDirectoryURL

        if destinationURL == nil {
            destinationURL = try? FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }

        if var destinationURL = destinationURL {

            destinationURL = destinationURL.appendingPathComponent(name)

            if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {

                do {

                    let context = CIContext()

                    try context.writeJPEGRepresentation(of: self, to: destinationURL, colorSpace: colorSpace, options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : quality])

                    return destinationURL.path

                } catch {
                    return nil
                }
            }
        }

        return nil
    }
}
