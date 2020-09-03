//
//  DistortionViewController.swift
//  ImageFilterEditor
//
//  Created by Morgan Smith on 9/2/20.
//  Copyright © 2020 Morgan Smith. All rights reserved.
//

import UIKit
import CoreImage
import Photos
import CoreImage.CIFilterBuiltins

class DistortionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var xCenterSlider: UISlider!
    @IBOutlet weak var yCenterSlider: UISlider!
    

    private let context = CIContext(options: nil)
    let filter = CIFilter(name: "CIVortexDistortion")!

    let imagePostController = ImagePostViewController.sharedPhoto

    var originalImage: UIImage? {
        didSet {
            guard let image = originalImage else { return }

            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale

            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)

            let scaledImage = image.imageByScaling(toSize: scaledSize)
            self.scaledImage = scaledImage
        }
    }

    var scaledImage: UIImage? {
        didSet {
            imageView.image = scaledImage
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imagePostController
        originalImage = imageView.image
    }

    @IBAction func saveTapped(_ sender: Any) {

    }

    @IBAction func radiusChanged(_ sender: UISlider) {
        updateImage()
    }
    @IBAction func angleChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func xCenterChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func yCenterChanged(_ sender: UISlider) {
        updateImage()
    }


    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }

    private func image(byFiltering image: UIImage) -> UIImage {

        guard let cgImage = image.cgImage else { return image}

        let ciImage = CIImage(cgImage: cgImage)
        let center = CIVector(x: CGFloat(xCenterSlider.value), y: CGFloat(yCenterSlider.value))

        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(radiusSlider.value, forKey: "inputRadius")
        filter.setValue(angleSlider.value, forKey: "inputAngle")
        filter.setValue(center, forKey: "inputCenter")


        guard let outputImage =  filter.outputImage else { return image }

        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }

        return UIImage(cgImage: outputCGImage)
    }



    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveDistortion" {
            if let imageVC = segue.destination as? ImagePostViewController {
                imageVC.filteredImage = imageView.image
            }
        }
    }

}

