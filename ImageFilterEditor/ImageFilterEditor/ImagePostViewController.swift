//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by David Wright on 5/6/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {

    private let context = CIContext()
    
    // Filters
    private let invertColorsFilter = CIFilter.colorInvert()
    private let vignetteFilter = CIFilter.vignette()
    private let lineOverlayFilter = CIFilter.lineOverlay()
    private let kaleidoscopeFilter = CIFilter.kaleidoscope()
    private let perspectiveTransformFilter = CIFilter.perspectiveTransform()
//    private let crystalizeFilter = CIFilter.crystallize()
//    private let pointillizeFilter = CIFilter.pointillize()
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale: CGFloat = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width*scale,
                                height: scaledSize.height*scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else { return }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var invertColorsSwitch: UISwitch!
    @IBOutlet weak var vignetteSlider: UISlider!
    @IBOutlet weak var lineOverlaySlider: UISlider!
    @IBOutlet weak var kaleidoscopeSlider: UISlider!
    @IBOutlet weak var perspectiveSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
    }
    
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func filterSettingsChanged(_ sender: Any) {
        updateImage()
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        var outputImage = inputImage
        
        // Invert Colors
        if invertColorsSwitch.isOn {
            invertColorsFilter.inputImage = outputImage
            guard let filteredImage = invertColorsFilter.outputImage else { return originalImage! }
            outputImage = filteredImage
        }
        
        // Vignette
        if vignetteSlider.value > 0 {
            vignetteFilter.inputImage = outputImage
            vignetteFilter.radius = vignetteSlider.value * 100
            vignetteFilter.intensity = vignetteSlider.value * 2
            if let filteredImage = vignetteFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        // Line Overlay (Sketchify)
        if lineOverlaySlider.value > 0 {
            //lineOverlayFilter.inputImage = outputImage
            lineOverlayFilter.setValue(outputImage, forKey: kCIInputImageKey)
            lineOverlayFilter.nrNoiseLevel = 0.09 - (lineOverlaySlider.value * 0.09)
            lineOverlayFilter.edgeIntensity = 0.5 + (lineOverlaySlider.value * 2.0)
            lineOverlayFilter.threshold = 0.5 - (lineOverlaySlider.value * 0.4)
            if let filteredImage = lineOverlayFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        // Kaleidoscope
        if kaleidoscopeSlider.value > 0 {
            //kaleidoscopeFilter.inputImage = outputImage
            kaleidoscopeFilter.setValue(outputImage, forKey: kCIInputImageKey)
            kaleidoscopeFilter.angle = kaleidoscopeSlider.value * Float.pi * 4
            kaleidoscopeFilter.count = Int(kaleidoscopeSlider.value * 20)
            kaleidoscopeFilter.center = CGPoint(x: outputImage.extent.midX,
                                                y: outputImage.extent.midY)
            if let filteredImage = kaleidoscopeFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        // PerspectiveTransform
        perspectiveTransformFilter.inputImage = outputImage
        let imageAspectRatio = outputImage.extent.width / outputImage.extent.height
        let leftSideYOffset: CGFloat = perspectiveSlider.value > 0.5 ? 0 : (CGFloat(0.5 - perspectiveSlider.value) * 500)
        let rightSideYOffset: CGFloat = perspectiveSlider.value < 0.5 ? 0 : (CGFloat(perspectiveSlider.value - 0.5) * 500)
        let leftSideXOffset: CGFloat = imageAspectRatio * leftSideYOffset * 2
        let rightSideXOffset: CGFloat = imageAspectRatio * rightSideYOffset * 2
        perspectiveTransformFilter.bottomLeft = CGPoint(x: outputImage.extent.minX + leftSideXOffset,
                                                        y: outputImage.extent.minY + leftSideYOffset)
        perspectiveTransformFilter.bottomRight = CGPoint(x: outputImage.extent.maxX - rightSideXOffset,
                                                         y: outputImage.extent.minY + rightSideYOffset)
        perspectiveTransformFilter.topLeft = CGPoint(x: outputImage.extent.minX + leftSideXOffset,
                                                     y: outputImage.extent.maxY - leftSideYOffset)
        perspectiveTransformFilter.topRight = CGPoint(x: outputImage.extent.maxX - rightSideXOffset,
                                                      y: outputImage.extent.maxY - rightSideYOffset)
        if let filteredImage = perspectiveTransformFilter.outputImage {
            outputImage = filteredImage
        }
        
        // I could not figure out how to get the crystalize and pointillize filters to work
        
        // Crystalize
        /*
        if slider2.value > 0 {
            //crystalizeFilter.inputImage = outputImage
            crystalizeFilter.setValue(outputImage, forKey: kCIInputImageKey)
            crystalizeFilter.radius = slider2.value * 10
            crystalizeFilter.center = CGPoint(x: outputImage.extent.midX,
                                              y: outputImage.extent.midY)
            if let filteredImage = crystalizeFilter.outputImage {
                outputImage = filteredImage
            }
        }
        */
        
        // Pointillize
        /*
        if slider2.value > 0 {
            //crystalizeFilter.inputImage = outputImage
            pointillizeFilter.setValue(outputImage, forKey: kCIInputImageKey)
            pointillizeFilter.radius = slider2.value * 60
            pointillizeFilter.center = CGPoint(x: outputImage.extent.midX,
                                               y: outputImage.extent.midY)
            if let filteredImage = pointillizeFilter.outputImage {
                outputImage = filteredImage
            }
        }
        */
        
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
        
        return UIImage(cgImage: renderedImage)
    }
}
