//
//  ViewController.swift
//  ImageFilters
//
//  Created by Jorge Alvarez on 3/9/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit
import CoreImage
import Photos
import CoreImage.CIFilterBuiltins // iOS 13 *

/*
You must add at least 5 filters. This page lists the filters that you can use. Note that some simply take in an inputImage parameter, while others have more parameters such as the CIMotionBlur, CIColorControls, etc. Use at least two or three of filters with a bit more complexity than just the inputImage.
Add whatever UI elements you want to the ImagePostViewController in order for them to add filters to their image after they've selected one. For the filters that require other parameters, add UI to allow the user to adjust the filter such as a slider for brightness, blur amount, etc.
Ensure that the controls to add your filters, adjust them, etc. are only available to the user at the apropriate time. For example, you shouldn't let the user add a filter if they haven't selected an image yet. And it doesn't make sense to show the adjustment UI if they selected a filter that has no adjustment.
 */

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstSlider: UISlider!
    @IBOutlet weak var secondSlider: UISlider!
    @IBOutlet weak var thirdSlider: UISlider!
    @IBOutlet weak var fourthSlider: UISlider!
    @IBOutlet weak var fifthSlider: UISlider!
    
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {return}
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale // 1x 2x or 3x or more
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    /// Allows us to render the image (like an oven for baking bread)
    private let context = CIContext(options: nil)
    
    @IBAction func firstSliderChanged(_ sender: UISlider) {
        updateImage()
    }
    
    /// Blur Filter
    @IBAction func secondSliderChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func thirdSliderChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func fourthSliderChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func fifthSliderChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        print("Add")
        presentImagePickerController()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        print("Save")
        savePhoto()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Use our storyboard placeholder to start
        //originalImage = imageView.image
    }
    
    func filterImage(_ image: UIImage) -> UIImage? {
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        /// Should these be properties???
        let filter = CIFilter.colorControls()
        let blurFilter = CIFilter.gaussianBlur()
        let sepiaFilter = CIFilter.sepiaTone()
        let monoFilter = CIFilter.colorMonochrome()
        let posterizeFilter = CIFilter.colorPosterize()
        
        /// Input
        filter.inputImage = ciImage
        filter.saturation = firstSlider.value
        
        /// Blur
        blurFilter.inputImage = filter.outputImage
        blurFilter.radius = secondSlider.value
        
        /// Sepia
        sepiaFilter.inputImage = blurFilter.outputImage
        sepiaFilter.intensity = thirdSlider.value
        
        /// Monochrome
        monoFilter.inputImage = sepiaFilter.outputImage
        monoFilter.intensity = fourthSlider.value
        
        /// Posterize
        posterizeFilter.inputImage = monoFilter.outputImage
        posterizeFilter.levels = fifthSlider.value
        
        /// Output
        guard let outputCIImage = posterizeFilter.outputImage else { return nil }
        
        // CIImage -> CGImage -> UIImage
        // Render the image (apply the filter to the image). Baking the cookies in the oven
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil // allows us to clear out the image
        }
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    private func savePhoto() {
        guard let originalImage = originalImage else { return }
        guard let processedImage = self.filterImage(originalImage.flattened) else { return }
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else { return }
            // Let the library know we are going to make changes
            PHPhotoLibrary.shared().performChanges({
                // Make a new photo creation request
                PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
            }, completionHandler: { (success, error) in
                if let error = error {
                    NSLog("Error saving photo: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    print("Saved image to Photo Library")
                    let alertController = UIAlertController(title: "Image Saved",
                                                            message: "Saved image to photo library",
                                                            preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
}

/// For accessing the photo library
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked Image")
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        picker.dismiss(animated: true, completion: nil)
    }
    
}

/// So images don't flip
extension UIImage {
    
    /// Resize the image to a max dimension from size parameter
    func imageByScaling(toSize size: CGSize) -> UIImage? {
        guard size.width > 0 && size.height > 0 else { return nil }
        
        let originalAspectRatio = self.size.width/self.size.height
        var correctedSize = size
        
        if correctedSize.width > correctedSize.width*originalAspectRatio {
            correctedSize.width = correctedSize.width*originalAspectRatio
        } else {
            correctedSize.height = correctedSize.height/originalAspectRatio
        }
        
        return UIGraphicsImageRenderer(size: correctedSize, format: imageRendererFormat).image { context in
            draw(in: CGRect(origin: .zero, size: correctedSize))
        }
    }
    
    /// Renders the image if the pixel data was rotated due to orientation of camera
    var flattened: UIImage {
        if imageOrientation == .up { return self }
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { context in
            draw(at: .zero)
        }
    }
}
