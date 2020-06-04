//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/1/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos
import CoreLocation

class ImagePostViewController: UIViewController {
    
    
    private let context = CIContext(options: nil)
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {
                scaledImage = nil
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
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sepiaSlider: UISlider!
    @IBOutlet weak var posterizeSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var sharpenSlider: UISlider!
    @IBOutlet weak var vignetteSlider: UISlider!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
        let sepiaFilter = CIFilter.sepiaTone()
        
        print(sepiaFilter.attributes)
    }
    
    
     private func updateViews() {
           guard let scaledImage = scaledImage else {return}
           imageView.image = filterImage(scaledImage)
       }
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else {return nil}
        let ciImage = CIImage(cgImage: cgImage)
    
        // Apply the Sepia Filter
        let sepiafilter = CIFilter.sepiaTone()
        sepiafilter.inputImage = ciImage
        sepiafilter.intensity = sepiaSlider.value
        guard let sepiaImage = sepiafilter.outputImage else { return nil }
        
        // Apply the Posterize Filter
        let posterizeFilter = CIFilter.colorPosterize()
        posterizeFilter.inputImage = sepiaImage
        posterizeFilter.levels = posterizeSlider.value
        guard let posterizeImage = posterizeFilter.outputImage else { return nil }
        
        // Apply the Blur Filter
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = posterizeImage
        blurFilter.radius = blurSlider.value
        guard let blurImage = blurFilter.outputImage else { return nil }
        
        // Apply the Sharpen Filter
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = blurImage
        sharpenFilter.sharpness = sharpenSlider.value
        guard let sharpenImage = sharpenFilter.outputImage else { return nil }
        
        // Apply the Vignette Filter
        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = sharpenImage
        vignetteFilter.intensity = vignetteSlider.value
        vignetteFilter.radius = vignetteSlider.value
        guard let vignetteImage = vignetteFilter.outputImage else { return nil }
        
        
        guard let outputCGImage = context.createCGImage(vignetteImage, from: CGRect(origin: .zero, size: image.size)) else {return image}
        return UIImage(cgImage: outputCGImage)
    }
    
    // MARK: - Slider Events
    @IBAction func sepiaChanged(_ sender: UISlider) {
        updateViews()
    }
    @IBAction func posterizeChanged(_ sender: UISlider) {
        updateViews()
    }
    @IBAction func blurChanged(_ sender: UISlider) {
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
    @IBAction func saveButtonPresset(_ sender: UIBarButtonItem) {
          saveAndFilterPhoto()
    }
    
    private func saveAndFilterPhoto() {
        guard let imageTitle = titleTextField.text, !imageTitle.isEmpty else { return }
        guard let author = authorTextField.text, !author.isEmpty else { return }
        guard let originalImage = originalImage else { return }
        guard let processedImage = filterImage(originalImage.flattened) else { return }
        
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

extension ImagePostViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension ImagePostViewController: UINavigationControllerDelegate {
    
}



