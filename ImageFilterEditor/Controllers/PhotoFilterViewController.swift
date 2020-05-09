//
//  PhotoFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Christian Lorenzo on 5/6/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import CoreImage
import Photos
import CoreImage.CIFilterBuiltins

class PhotoFilterViewController: UIViewController {
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var sharpenSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    
    private let context = CIContext()
    private let colorControlsFilter = CIFilter.colorControls()
    private let blurFilter = CIFilter.gaussianBlur()
    private let sharpenLuminance = CIFilter.sharpenLuminance()
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale: CGFloat = 0.5 //UIScreen.main.scale  //We can play with the number too. Works better by putting 0.5
            
            scaledSize = CGSize(width: scaledSize.width*scale,
                                height: scaledSize.height*scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else { return }
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let filter = CIFilter.gaussianBlur() //Built-in filter from Apple
        //        print(filter)
        //        print(filter.attributes)
        
        originalImage = imageView.image
        
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        let inputImage = inputImage
        colorControlsFilter.inputImage = inputImage
        colorControlsFilter.saturation = saturationSlider.value
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value
        
        sharpenLuminance.inputImage = colorControlsFilter.outputImage
        sharpenLuminance.sharpness = sharpenSlider.value
        
        blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
        blurFilter.radius = blurSlider.value
        
        sharpenLuminance.inputImage = colorControlsFilter.outputImage
        sharpenLuminance.sharpness = sharpenSlider.value
        
        
        
        //Grab the output
        
        //guard let outputImage1 = sharpenLuminance.outputImage else { return originalImage!}
        guard let outputImage  = blurFilter.outputImage else { return originalImage! }
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
        //guard let rederedImage2 = context.createCGImage(outputImage1, from: inputImage.extent) else { return originalImage!}
        
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
            print("The Photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Actions
    
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        
        presentImagePickerController()
    }
    
    @IBAction func savePhotoButtonPressed(_ sender: Any) {
        
        guard let originalImage = originalImage?.flattened,
            let ciImage = CIImage(image: originalImage) else { return }
        
        let processedImage = self.image(byFiltering: ciImage)
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
            }) { (success, error) in
                if let error = error {
                    print("Error saving photo: \(error)")
                    // NSLog("%@", error)
                    return
                }
                
                DispatchQueue.main.async {
                    self.presentSuccessFulSaveAlert()
                }
            }
        }
    }
    
    private func presentSuccessFulSaveAlert() {
        let alert = UIAlertController(title: "Photo Saved!", message: "The photo has been saved to your Photo Library!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Slider events:
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        
        updateImage()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        
        updateImage()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        
        updateImage()
    }
    
    @IBAction func blurCharged(_ sender: Any) {
        
        updateImage()
    }
    
    @IBAction func sharpenChanged(_ sender: Any) {
        
        updateImage()
    }
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as?UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


