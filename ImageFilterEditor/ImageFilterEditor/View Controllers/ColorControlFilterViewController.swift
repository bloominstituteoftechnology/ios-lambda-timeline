//
//  ColorControlFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Jessie Ann Griffin on 5/8/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit

protocol ColorControlFilterProtocol {
    func applyColorControlFilter() -> CIFilter
    
    var saturation: Double { get }
    var brightness: Double { get }
    var contrast: Double { get }
}
class ColorControlFilterViewController: UIViewController {
    
    
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var constrastSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    private let colorControlFilter = CIFilter.colorControls()
    
    var passedImage: UIImage?
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    var context: CIContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = passedImage
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        colorControlFilter.inputImage = inputImage
        colorControlFilter.saturation = saturationSlider.value
        colorControlFilter.brightness = brightnessSlider.value
        colorControlFilter.contrast = constrastSlider.value
        
        //            blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
        //            blurFilter.radius = blurSlider.value
        
        guard let outputImage = colorControlFilter.outputImage else { return passedImage! }
        
        guard let renderedImage = context?.createCGImage(outputImage, from: inputImage.extent) else { return passedImage! }
        
        return UIImage(cgImage: renderedImage)
    }
    @IBAction func saturationChanged(_ sender: UISlider) {
        updateImage()
    }
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateImage()
    }
    @IBAction func contrastChanged(_ sender: UISlider) {
        updateImage()
    }
    
}
