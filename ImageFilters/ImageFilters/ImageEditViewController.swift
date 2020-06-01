//
//  ImageEditViewController.swift
//  ImageFilters
//
//  Created by Mark Poggi on 6/1/20.
//  Copyright © 2020 Mark Poggi. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImageEditViewController: UIViewController {

    enum filterKey: String {
        case inputImage = "inputImage"
        case exposure = "inputEV"
        case posterize = "inputLevels"
        case vibrance = "inputAmount"
        case sharpen = "inputSharpness"
        case vignetteRadius = "inputRadius"
        case vignetteIntensity = "inputIntensity"
    }

    // MARK: - Properties

    let exposureFilter = CIFilter(name: "CIExposureAdjust")
    let posterizeFilter = CIFilter(name: "CIColorPosterize")
    let vibranceFilter = CIFilter(name: "CIVibrance")
    let sharpenFilter = CIFilter(name: "CISharpenLuminance")
    let vignetteFilter = CIFilter(name: "CIVignette")
    private let context = CIContext(options: nil)

    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {
                scaledImage = nil // clear image if set to nil
                return
            }
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }

    private var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var exposureSlider: UISlider!
    @IBOutlet weak var posterizeSlider: UISlider!
    @IBOutlet weak var vibranceSlider: UISlider!
    @IBOutlet weak var sharpenSlider: UISlider!
    @IBOutlet weak var vignetteSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        resetDefaultValues()
        originalImage = imageView.image

    }

    private func resetDefaultValues() {
        exposureSlider.value = 0
        posterizeSlider.value = 6
        vibranceSlider.value = 0
        sharpenSlider.value = 0
        vignetteSlider.value = 1
    }

    private func updateViews() {
        guard let scaledImage = scaledImage else {return}
        imageView.image = filterImage(scaledImage)
    }

    private func filterImage(_ image: UIImage) -> UIImage? {

        // UIImage -> CGImage -> CIImage

        guard let cgImage = image.cgImage else {return nil}

        let ciImage = CIImage(cgImage: cgImage)

        // Filtering
        exposureFilter?.setValue(ciImage, forKey: filterKey.inputImage.rawValue)
        exposureFilter?.setValue(exposureSlider.value, forKey: filterKey.exposure.rawValue)
        guard let exposureCIImage = exposureFilter?.outputImage else { return image }

        posterizeFilter?.setValue(exposureCIImage, forKey: filterKey.inputImage.rawValue)
        posterizeFilter?.setValue(posterizeSlider.value, forKey: filterKey.posterize.rawValue)
        guard let posterizeCIImage = posterizeFilter?.outputImage else { return image }

        vibranceFilter?.setValue(posterizeCIImage, forKey: filterKey.inputImage.rawValue)
        vibranceFilter?.setValue(vibranceSlider.value, forKey: filterKey.vibrance.rawValue)
        guard let vibranceCIImage = vibranceFilter?.outputImage else { return image }

        sharpenFilter?.setValue(vibranceCIImage, forKey: filterKey.inputImage.rawValue)
        sharpenFilter?.setValue(sharpenSlider.value, forKey: filterKey.sharpen.rawValue)
        guard let sharpenCIImage = sharpenFilter?.outputImage else { return image }

        vignetteFilter?.setValue(sharpenCIImage, forKey: filterKey.inputImage.rawValue)
        vignetteFilter?.setValue(vignetteSlider.value, forKey: filterKey.vignetteRadius.rawValue)
        vignetteFilter?.setValue(vignetteSlider.value, forKey: filterKey.vignetteIntensity.rawValue)
        guard let vignetteCIImage = vignetteFilter?.outputImage else { return image }

        guard let outputCGImage = context.createCGImage(vignetteCIImage, from: CGRect(origin: .zero, size: image.size)) else {return image}

        return UIImage(cgImage: outputCGImage)
    }


    // MARK: - Slider Events

    @IBAction func exposureChanged(_ sender: UISlider) {
        updateViews()
    }

    @IBAction func posterizeChanged(_ sender: UISlider) {
        updateViews()
    }

    @IBAction func vibranceChanged(_ sender: UISlider) {
        updateViews()
    }

    @IBAction func sharpenChanged(_ sender: UISlider) {
        updateViews()
    }

    @IBAction func vignetteChanged(_ sender: Any) {
        updateViews()
    }

    // MARK: - Actions

    @IBAction func choosePhotoButtonPressed(_ sender: UIBarButtonItem) {
        presentImagePickerController()
    }

    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { print("Error: the photo libary is not available.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }

    @IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {

        resetDefaultValues()
        updateViews()
    }

    @IBAction func saveButtonPresset(_ sender: UIBarButtonItem) {
          saveAndFilterPhoto()
    }
    

    private func saveAndFilterPhoto() {
        guard let originalImage = originalImage else { return }

        guard let processedImage = filterImage(originalImage) else { return }

        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else { return } // TODO: Handle other cases

            PHPhotoLibrary.shared().performChanges({

                PHAssetChangeRequest.creationRequestForAsset(from: processedImage)

            }) { (success, error) in
                if let error = error {
                    print("Error saving photo: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    print("Saved photo")
                }
            }
        }
    }
}

// MARK: - Extensions

extension ImageEditViewController: UIImagePickerControllerDelegate {

    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)

    }
}

extension ImageEditViewController: UINavigationControllerDelegate {

}
