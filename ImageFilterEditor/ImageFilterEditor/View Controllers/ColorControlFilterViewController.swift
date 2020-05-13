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
//    {
//        didSet {
//            if let passedImage = passedImage {
//                scaledImage = CIImage(image: passedImage)
//            }
//        }
//    }
    
    var scaledImage: CIImage? {
        didSet {
            guard let passedImage = passedImage else { return }
            scaledImage = CIImage(image: passedImage)
            updateImage()
        }
    }
    
    var context: CIContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateImage()
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = passedImage
        }
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        colorControlFilter.inputImage = inputImage
        colorControlFilter.saturation = saturationSlider.value
        colorControlFilter.brightness = brightnessSlider.value
        colorControlFilter.contrast = constrastSlider.value

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
