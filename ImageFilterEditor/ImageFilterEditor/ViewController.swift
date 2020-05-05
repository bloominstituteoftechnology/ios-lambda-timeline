//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Mark Gerrior on 5/4/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ViewController: UIViewController {

    // MARK: - Properties

    let context = CIContext(options: nil)

    var originalImage: UIImage? {
        didSet {
            // resize the scaledImage and set it view
            guard let originalImage = originalImage else { return }
            // Height and width
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale  // Size of pixels on this device: 1x, 2x, or 3x
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }

    var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Actions

    @IBAction func addButton(_ sender: Any) {
        presentImagePickerControllerToUser()
    }

    // MARK: - Outlets

    @IBOutlet weak var imageView: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Private Functions
    private func updateViews() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }

    private func presentImagePickerControllerToUser() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    private func filterImage(_ image: UIImage) -> UIImage? {

        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // Filter image step
        let filter = CIFilter(name: "CIColorControls")! // build-in filter from Apple
//        let filter2 = CIFilter.colorControls()
//        filter2.brightness = brightnessSlider.value

        // setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey /* "inputImage" */)
//        filter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)
//        filter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
//        filter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)

        // CIImage -> CGImage -> UIImage
//        guard let outputCIImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
        guard let outputCIImage = filter.outputImage else { return nil }

        // Render the image (do image processing here)
        guard let outputCGImage = context.createCGImage(outputCIImage,
                                                        from: CGRect(origin: .zero, size: image.size)) else {
                                                            return nil
        }

        return UIImage(cgImage: outputCGImage)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ViewController: UINavigationControllerDelegate {
}

