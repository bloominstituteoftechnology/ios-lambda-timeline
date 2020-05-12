//
//  WhitePointFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Jessie Ann Griffin on 5/8/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit

protocol WhitePointFilterProtocol {
    func applyWhitePointFilter() -> CIFilter
    
    var color: UIColor { get }
}

class WhitePointFilterViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private let whitePointAdjustmentFilter = CIFilter.whitePointAdjust()

    var image: UIImage?
       
       var scaledImage: UIImage? {
           didSet {
               updateImage()
           }
       }
       
       private let context = CIContext()
       
       override func viewDidLoad() {
           super.viewDidLoad()
           updateViews()
       }
       
       func updateViews() {
           imageView.image = scaledImage
       }
       
       private func updateImage() {
           guard let transferredImage = CIImage(image: scaledImage!) else { return }
//           imageView.image = image(byFiltering: transferredImage)
       }
//
//    private func image(byFiltering inputImage: CIImage) -> UIImage {
//
//        colorControlFilter.inputImage = inputImage
//        colorControlFilter.saturation = saturationSlider.value
//        colorControlFilter.brightness = brightnessSlider.value
//        colorControlFilter.contrast = constrastSlider.value
//
//        //            blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
//        //            blurFilter.radius = blurSlider.value
//
//        guard let outputImage = colorControlFilter.outputImage else { return scaledImage! }
//
//        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return scaledImage! }
//
//        return UIImage(cgImage: renderedImage)
//    }
}
