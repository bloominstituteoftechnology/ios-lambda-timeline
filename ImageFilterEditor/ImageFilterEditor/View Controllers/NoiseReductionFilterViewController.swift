//
//  NoiseReductionFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Jessie Ann Griffin on 5/8/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit

protocol NoiseFilterProtocol {
    func applyNoiseFilter() -> CIFilter
    
    var noise: Double { get }
    var sharpness: Double { get }
}

class NoiseReductionFilterViewController: UIViewController {

    @IBOutlet weak var noiseFilterSlider: UISlider!
    @IBOutlet weak var sharpnessFilterSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    var noiseDelegate: NoiseFilterProtocol?
    
    private let noiseReductionFilter = CIFilter.noiseReduction()
    
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
        
        noiseReductionFilter.inputImage = inputImage
        noiseReductionFilter.noiseLevel = noiseFilterSlider.value
        noiseReductionFilter.sharpness = sharpnessFilterSlider.value

        guard let outputImage = noiseReductionFilter.outputImage else { return passedImage! }

        guard let renderedImage = context?.createCGImage(outputImage, from: inputImage.extent) else { return passedImage! }
        
        return UIImage(cgImage: renderedImage)
    }
    
    @IBAction func noiseValueChanged(_ sender: UISlider) {
        updateImage()
    }
    @IBAction func sharpnessValueChanged(_ sender: UISlider) {
        updateImage()
    }
    
}
