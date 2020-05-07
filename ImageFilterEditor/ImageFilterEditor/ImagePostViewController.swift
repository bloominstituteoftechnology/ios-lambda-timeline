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
            colorInvertFilter.inputImage = inputImage
            guard let filteredImage = colorInvertFilter.outputImage else { return originalImage! }
            outputImage = filteredImage
        }
        
        // Vignette
        vignetteFilter.inputImage = outputImage
        vignetteFilter.radius = slider1.value * 30
        vignetteFilter.intensity = slider1.value * 2
        guard let filteredImage = vignetteFilter.outputImage else { return originalImage! }
        outputImage = filteredImage
        
        // Crystalize
        
        
        // Line Overlay
        
        
        // Pointillize
        
        
        // Kaleidoscope
        
        
        // PerspectiveTransform
        
        
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
        
        return UIImage(cgImage: renderedImage)
    }
}
