//
//  ImageFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Christy Hicks on 5/6/20.
//  Copyright © 2020 Knight Night. All rights reserved.
//

import UIKit
import CoreImage
import Photos
import CoreImage.CIFilterBuiltins

class ImageFilterViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var saturationSlider: UISlider!
    @IBOutlet var brightnessSlider: UISlider!
    @IBOutlet var contrastSlider: UISlider!
    @IBOutlet var exposureSlider: UISlider!
    
    // MARK: - Properties
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale: CGFloat = 1
            
            scaledSize = CGSize(width: scaledSize.width*scale,
                                height: scaledSize.height*scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else { return }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    private let context = CIContext()
    private let colorControlsFilter = CIFilter.colorControls()
    private let exposureFilter = CIFilter.exposureAdjust()
    private let invertColorsFilter = CIFilter.colorInvert()
//    private let greyscaleFilter = CIFilter.photoEffectNoir()
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalImage = imageView.image
    }
    
    var isInverted: Bool = false
//    var isGreyscale: Bool = false
    
    
    // MARK: - Actions
    @IBAction func choosePhoto(_ sender: UIBarButtonItem) {
        presentImagePickerController()
    }
    
    @IBAction func invertColors(_ sender: UIButton) {
        guard let inputImage = scaledImage else { return }
        invertColorsFilter.inputImage = inputImage
        scaledImage = invertColorsFilter.outputImage
        isInverted.toggle()
    }
    
//    @IBAction func greyscale(_ sender: UIButton) {
//        guard let inputImage = scaledImage else { return }
//        greyscaleFilter.inputImage = inputImage
//        scaledImage = greyscaleFilter.outputImage
//        isGreyscale.toggle()
//    }
    
    @IBAction func savePhoto(_ sender: UIButton) {
        guard let originalImage = originalImage?.flattened, let ciImage = CIImage(image: originalImage) else { return }
        
        let processedImage = self.image(byFiltering: ciImage)
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
            }) { (success, error) in
                if let error = error {
                    print("Error saving photo: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.presentSuccessfulSaveAlert()
                }
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        updateImage()
    }
    
    
    // MARK: - Methods
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        colorControlsFilter.inputImage = inputImage
        colorControlsFilter.saturation = saturationSlider.value
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value
        
        exposureFilter.inputImage = colorControlsFilter.outputImage
        exposureFilter.ev = exposureSlider.value
        
        guard let outputImage = exposureFilter.outputImage else { return originalImage! }
        
        guard let renderedImage = context.createCGImage(outputImage, from: outputImage.extent) else { return originalImage! }
        
        return UIImage(cgImage: renderedImage)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func presentSuccessfulSaveAlert() {
        let alert = UIAlertController(title: "Photo Saved!", message: "The photo has been saved to your Photo Library!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}



