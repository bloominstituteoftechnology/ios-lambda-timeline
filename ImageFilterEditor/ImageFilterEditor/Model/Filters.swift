//
//  Filters.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum FilterType: String, CaseIterable {
    case noFilter = "No Filter"
    case motionBlur = "Motion Blur"
    case colorMonochrome = "Color Monochrome"
    case circleSplash = "Circle Splash"
    case sharpenLuminance = "Sharpen Luminance"
    case bloom = "Bloom"
}

struct Filters {
    // MARK: Properties
    let context = CIContext(options: nil)
    
    
    //MARK: Filters
    ///blur filters
    func motionBlur(for image: UIImage, radius: Float, angle: Float) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        let motionBlur = CIFilter.motionBlur()
        motionBlur.inputImage = ciImage
        motionBlur.radius = radius
        motionBlur.angle = angle
        
        guard let outputImage = motionBlur.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    ///color effect filters
    func colorMonochrome(for image: UIImage, color: CIColor) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        let monochrome = CIFilter.colorMonochrome()
        monochrome.inputImage = ciImage
        monochrome.color = color //TODO: Attach to UI
        monochrome.intensity = 1.0 //TODO: Attach to UI
        
        guard let outputImage = monochrome.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    ///distortion effect filters
    func circleSplash(for image: UIImage, at center: CIVector, radius: Float) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        let circleSplash = CIFilter(name: "CICircleSplashDistortion")!
        circleSplash.setValuesForKeys(["inputImage" : ciImage,
                                        "inputCenter" : center,//change center to center of view
                                        "inputRadius" : radius])
        
        guard let outputImage = circleSplash.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    ///luminance filters
    func sharpenLuminance(for image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        let sharpen = CIFilter.sharpenLuminance()
        sharpen.inputImage = ciImage
        sharpen.sharpness = 0.50 //TODO: attach to UI
        
        guard let outputImage = sharpen.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    //stylized filters
    func bloom(for image: UIImage, with intensity: Float = 10.0) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        let bloom = CIFilter.bloom()
        bloom.inputImage = ciImage
        bloom.radius = 0.5 //TODO: Attach to UI
        bloom.intensity = intensity //TODO: Attach to UI
        
        guard let outputImage = bloom.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
}
