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
    private let colorInvertFilter = CIFilter.colorInvert()
    private let vignetteFilter = CIFilter.vignette()
    private let crystalizeFilter = CIFilter.crystallize()
    private let lineOverlayFilter = CIFilter.lineOverlay()
    private let pointillizeFilter = CIFilter.pointillize()
    private let kaleidoscopeFilter = CIFilter.kaleidoscope()
    private let perspectiveTransformFilter = CIFilter.perspectiveTransform()
    
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
    
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var slider4: UISlider!
    @IBOutlet weak var invertColorsSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    
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
            colorInvertFilter.inputImage = outputImage
            guard let filteredImage = colorInvertFilter.outputImage else { return originalImage! }
            outputImage = filteredImage
        }
        
        // Vignette
        if slider1.value > 0 {
            vignetteFilter.inputImage = outputImage
            vignetteFilter.radius = slider1.value * 100
            vignetteFilter.intensity = slider1.value * 2
            if let filteredImage = vignetteFilter.outputImage {
                outputImage = filteredImage
            }
        }
        //print(crystalizeFilter.attributes)
        // Crystalize
        
        
        // Line Overlay
        
        
        // Pointillize
        
        // Line Overlay
        if slider3.value > 0 {
            //lineOverlayFilter.inputImage = outputImage
            lineOverlayFilter.setValue(outputImage, forKey: kCIInputImageKey)
            lineOverlayFilter.nrNoiseLevel = 0.09 - (slider3.value * 0.09)
            lineOverlayFilter.edgeIntensity = 0.5 + (slider3.value * 2.0)
            lineOverlayFilter.threshold = 0.5 - (slider3.value * 0.4)
            if let filteredImage = lineOverlayFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        // Kaleidoscope
        if slider4.value > 0 {
            //kaleidoscopeFilter.inputImage = outputImage
            kaleidoscopeFilter.setValue(outputImage, forKey: kCIInputImageKey)
            kaleidoscopeFilter.angle = slider4.value * Float.pi * 4
            kaleidoscopeFilter.count = Int(slider4.value * 20)
            kaleidoscopeFilter.center = CGPoint(x: outputImage.extent.midX,
                                                y: outputImage.extent.midY)
            if let filteredImage = kaleidoscopeFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        // PerspectiveTransform
        perspectiveTransformFilter.inputImage = outputImage
        let imageAspectRatio = outputImage.extent.width / outputImage.extent.height
        let leftSideYOffset: CGFloat = slider2.value > 0.5 ? 0 : (CGFloat(0.5 - slider2.value) * 500)
        let rightSideYOffset: CGFloat = slider2.value < 0.5 ? 0 : (CGFloat(slider2.value - 0.5) * 500)
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
        
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
        
        return UIImage(cgImage: renderedImage)
    }
}
