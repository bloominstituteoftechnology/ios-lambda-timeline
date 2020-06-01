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

class ImagePostViewController: UIViewController {
    
    // MARK: - Properites
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
    @IBOutlet weak var posterizeSlider: UISlider!
    @IBOutlet weak var sepiaSlider: UISlider!
    @IBOutlet weak var luminanceSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var monoSlider: UISlider!
    @IBOutlet weak var chromeSlider: UISlider!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
    }
    
    private func updateViews() {
    }
    
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        // TODO: show the photo picker so we can choose on-device photos
        // UIImagePickerController + Delegate
        presentImagePickerController()
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func savePhotoButtonPressed(_ sender: UIButton) {
        // TODO: Save to photo library
        saveAndFilterPhoto()
    }
    
    private func saveAndFilterPhoto() {
        guard let originalImage = originalImage?.flattened, let ciImage = CIImage(image: originalImage) else { return }
        
    }
    
    
    @IBAction func posterizeChanged(_ sender: Any) {
        updatePosterizedImage()
    }
    
    @IBAction func sepiaChanged(_ sender: Any) {
        updateSepiaToneImage()
    }
    
    @IBAction func luminanceRadiusChanged(_ sender: Any) {
        updateLuminanceImage()
    }
    
    @IBAction func luminanceChanged(_ sender: Any) {
        updateLuminanceImage()
    }
    
    @IBAction func monoChanged(_ sender: Any) {
        updateMonoEffect()
    }
    
    @IBAction func chromeChanged(_ sender: Any ) {
        updateChromeEffect()
    }
    
    
    
    func posterizeImage(_ image: UIImage) -> UIImage? {
        
        // UIImage > CGImage > CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.colorPosterize()
        filter.inputImage = ciImage
        filter.levels = posterizeSlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (apply the filter to the image)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        // CIImage > CGImage > UIImage
        return UIImage(cgImage: outputCGImage)
    }
    
    func sepiaToneImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.sepiaTone()
        filter.inputImage = ciImage
        filter.intensity = sepiaSlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func sharpenLuminanceImage(_ image: UIImage) -> UIImage? {
           guard let cgImage = image.cgImage else { return nil }
           let ciImage = CIImage(cgImage: cgImage)
           
           let filter = CIFilter.sharpenLuminance()
           filter.inputImage = ciImage
           filter.sharpness = luminanceSlider.value
           filter.radius = radiusSlider.value
           
           
           guard let outputCIImage = filter.outputImage else { return nil }
           
           guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
           
           return UIImage(cgImage: outputCGImage)
       }
    
    func monoEffectImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.photoEffectMono()
        filter.inputImage = ciImage
        
        guard let outputCIImage = filter.outputImage else {return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func chromeEffectImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.photoEffectChrome()
        filter.inputImage = ciImage
        
        guard let outputCIImage = filter.outputImage else {return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func updatePosterizedImage() {
        if let scaledImage = scaledImage {
            imageView.image = posterizeImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    func updateSepiaToneImage() {
        if let scaledImage = scaledImage {
            imageView.image = sepiaToneImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    func updateLuminanceImage() {
        if let scaledImage = scaledImage {
            imageView.image = sharpenLuminanceImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    func updateMonoEffect() {
        if let scaledImage = scaledImage {
                   imageView.image = monoEffectImage(scaledImage)
               } else {
                   imageView.image = nil
               }
    }
    
    func updateChromeEffect() {
        if let scaledImage = scaledImage {
            imageView.image = chromeEffectImage(scaledImage)
        } else {
            imageView.image = nil
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



