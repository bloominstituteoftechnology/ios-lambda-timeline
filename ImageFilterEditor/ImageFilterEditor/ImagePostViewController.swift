//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Harmony Radley on 7/6/20.
//  Copyright © 2020 Harmony Radley. All rights reserved.
//

import UIKit
import CoreImage
import Photos
import CoreImage.CIFilterBuiltins

class ImagePostViewController: UIViewController {

    @IBOutlet var inputRadiusSlider: UISlider!
    @IBOutlet var inputAngleSlider: UISlider!
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        originalImage = imageView.image
    }

    // MARK: - Properties

       private let context = CIContext(options: nil)

       var originalImage: UIImage? {
           didSet {
               // We want to scale down the image to make it easier to filter until the user is ready to save the image
               guard let image = originalImage else { return }

               // height and width of the image view
               var scaledSize = imageView.bounds.size

               // 1, 2, or 3
               let scale = UIScreen.main.scale

               scaledSize = CGSize(width: scaledSize.width * scale,
                                   height: scaledSize.height * scale)

               // `imageByScaling` is coming from the UIImage+Scaling.swift
               let scaledImage = image.imageByScaling(toSize: scaledSize)

               self.scaledImage = scaledImage
           }
       }

       var scaledImage: UIImage? {
           didSet {
               imageView.image = scaledImage
           }
       }

    // MARK: - Slider events

    @IBAction func inputRadiusChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func inputAngleChanged(_ sender: UISlider) {
        updateImage()
    }


    // MARK: - Image Filtering

    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }

    private func image(byFiltering image: UIImage) -> UIImage {

        guard let cgImage = image.cgImage else { return image }

        let ciImage = CIImage(cgImage: cgImage)

        let filter1 = CIFilter.motionBlur()

        filter1.inputImage = ciImage
        filter1.radius = inputRadiusSlider.value
        filter1.angle = inputAngleSlider.value

        guard let outputImage = filter1.outputImage else {
            return image
        }

        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }

        return UIImage(cgImage: outputCGImage)
    }
}

