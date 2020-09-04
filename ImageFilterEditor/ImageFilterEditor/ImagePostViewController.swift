//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Clayton Watkins on 9/2/20.
//  Copyright © 2020 Clayton Watkins. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImagePostViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var vignetteSilder: UISlider!
    @IBOutlet weak var whitePointSlider: UISlider!
    @IBOutlet weak var falseColorSilder: UISlider!
    @IBOutlet weak var monoChromaticSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    var originalImage: UIImage?{
        didSet{
            guard let originalImage = originalImage else {
                scaledImage = nil
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = imageView.contentScaleFactor
            
            scaledSize = CGSize(width: scaledSize.width*scale, height: scaledSize.height*scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    var scaledImage: CIImage?{
        didSet{
            updateImage()
        }
    }
    
    let context = CIContext()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
    }
    
    // MARK: - Methods
    private func image(byFiltering image: CIImage) -> UIImage? {
        let inputImage = image
        
        // Blur
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = inputImage
        blurFilter.radius = blurSlider.value
        
        // Sharpen
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = blurFilter.outputImage?.clampedToExtent()
        sharpenFilter.sharpness =  falseColorSilder.value
     
        // Vignette
        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = sharpenFilter.outputImage?.clampedToExtent()
        vignetteFilter.intensity = vignetteSilder.value
        vignetteFilter.radius = vignetteSilder.value
        
        // Sepia
        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.inputImage = vignetteFilter.outputImage?.clampedToExtent()
        sepiaFilter.intensity = whitePointSlider.value
        
        // MonoChromatic
        let monochromaticFilter = CIFilter.colorMonochrome()
        monochromaticFilter.inputImage = sepiaFilter.outputImage?.clampedToExtent()
        monochromaticFilter.intensity = monoChromaticSlider.value
        
        guard let outputImage = monochromaticFilter.outputImage else { return nil }
        
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil}
        
        return UIImage(cgImage: renderedCGImage)
        
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    // MARK: - IBActions
    @IBAction func blurChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func vignetteChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func whitePointChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func falseColorChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func monoChromaticChanged(_ sender: Any) {
        updateImage()
    }
    
    
}
