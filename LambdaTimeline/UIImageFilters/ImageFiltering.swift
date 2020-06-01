//
//  ImageFiltering.swift
//  LambdaTimeline
//
//  Created by Patrick Millet on 6/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageFiltering: UIViewController {
    
    private let context = CIContext(options: nil)
        
        private var originalImage: UIImage? {
            didSet {
                guard let originalImage = originalImage else {
                    scaledImage = nil // clear out image if original image fails
                    return
                }
                
                var scaledSize = imageView.bounds.size
                let scale = UIScreen.main.scale
                scaledSize = CGSize(width: scaledSize.width * scale,
                                    height: scaledSize.height * scale)
                scaledImage = originalImage.imageByScaling(toSize: scaledSize)
            }
        }
        
        private var scaledImage: UIImage? {
            didSet {
                updateViews()
            }
        }
        
        @IBOutlet weak var brightnessSlider: UISlider!
        @IBOutlet weak var contrastSlider: UISlider!
        @IBOutlet weak var saturationSlider: UISlider!
        @IBOutlet weak var blurSlider: UISlider!
        @IBOutlet weak var imageView: UIImageView!
        @IBOutlet weak var sharpnessSlider: UISlider!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let filter = CIFilter.colorControls()
            filter.brightness = 1 // Ranges are determined by the filter / documentation
            //print(filter.attributes)
            
            originalImage = imageView.image
        }
        
        private func filterImage(_ image: UIImage) -> UIImage? {
            // UIImage -> CGImage -> CIImage
            guard let cgImage = image.cgImage else { return nil }
            
            let ciImage = CIImage(cgImage: cgImage)
            
            // Filtering
            let filter = CIFilter.colorControls() // May not work for some custom filters (KVC protocol)
            filter.inputImage = ciImage
            filter.brightness = brightnessSlider.value
            filter.contrast = contrastSlider.value
            filter.saturation = saturationSlider.value
            
            
            // CIImage -> CGImage -> UIImage
            guard let outputCIImage = filter.outputImage else { return nil }
            
            // Takes in the color filters and adds a blur filter
            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.inputImage = outputCIImage
            blurFilter.radius = blurSlider.value
            
            guard let blurFilterImage = blurFilter.outputImage else { return nil }
            
            // Applies a sharpen filter to the image
            
            let sharpenFilter = CIFilter.sharpenLuminance()
            sharpenFilter.inputImage = blurFilterImage
            sharpenFilter.sharpness = sharpnessSlider.value
            
            guard let sharpenFilterImage = sharpenFilter.outputImage else { return nil }
            
            //Render image
            guard let outputCGImage = context.createCGImage(sharpenFilterImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            
            return UIImage(cgImage: outputCGImage)
        }
        
        private func updateViews() {
            guard let scaledImage = scaledImage else { return }
            imageView.image = filterImage(scaledImage)
        }
        
        // MARK: Actions
        
        @IBAction func choosePhotoButtonPressed(_ sender: Any) {
            //TODO: Inject the image from the postVC and
        }
        
        private func presentImagePickerController() {
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                print("Error: The photo library is not available")
                return
            }
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion: nil)
        }
        
        
        @IBAction func savePhotoButtonPressed(_ sender: UIBarButtonItem) {
            // TODO: Save to photo library
            saveAndFilterPhoto()
        }
        
        private func saveAndFilterPhoto() {
            
            //TODO: Use a delegate to pass the filtered photo to the postVC
            guard let originalImage = originalImage else { return }
            
            guard let filteredImage = filterImage(originalImage) else { return }
            
            
            PHPhotoLibrary.requestAuthorization { (status) in
                guard status == .authorized else { return }
            }
            
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetCreationRequest.creationRequestForAsset(from: filteredImage)
                
            }) { (success, error) in
                if let error = error {
                    print("Error saving photo: 😢 \(error)")
                    return
                }
                DispatchQueue.main.async {
                    print("Saved photo")
                }
            }
        }
        

        // MARK: Slider events
        
        @IBAction func brightnessChanged(_ sender: UISlider) {
            updateViews()
        }
        
        @IBAction func contrastChanged(_ sender: Any) {
            updateViews()
        }
        
        @IBAction func saturationChanged(_ sender: Any) {
            updateViews()
        }
    
    @IBAction func blurChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func sharpnessChanged(_ sender: Any) {
        updateViews()
    }
    }



    extension ImageFiltering: UIImagePickerControllerDelegate {
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                originalImage = image
            }
            dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.contrastSlider.value = 1
                    self.brightnessSlider.value = 0
                    self.saturationSlider.value = 1
                    self.updateViews()
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
}

    extension ImageFiltering: UINavigationControllerDelegate {
        
    }
