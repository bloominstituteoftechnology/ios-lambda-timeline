//
//  ImageFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Hunter Oppel on 6/1/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImageFilterViewController: UIViewController {
    
    private var context = CIContext(options: nil)
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {
                scaledImage = nil
                sliderStackView.isHidden = true
                saveButton.isHidden = true
                return
            }
            
            sliderStackView.isHidden = false
            saveButton.isHidden = false
            
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
    @IBOutlet weak var guassianBlurSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var hueSlider: UISlider!
    
    @IBOutlet weak var sliderStackView: UIStackView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let guassianFilter = CIFilter.gaussianBlur()
        let colorControlsFilter = CIFilter.colorControls()
        let twirlFilter = CIFilter.hueAdjust()
        
        print(guassianFilter.attributes)
        print("================================")
        print(colorControlsFilter.attributes)
        print("================================")
        print(twirlFilter.attributes)
        
        // Setting this manually because the storyboard didn't play nice with the numbers
        hueSlider.minimumValue = -3.141592653589793
        hueSlider.maximumValue = 3.141592653589793
    }
    
    private func updateViews() {
        guard let scaledImage = scaledImage else { return }
        imageView.image = filterImage(scaledImage)
    }
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        // Apply gaussian blur
        let gaussianFilter = CIFilter.gaussianBlur()
        gaussianFilter.inputImage = ciImage
        gaussianFilter.radius = guassianBlurSlider.value
        guard let gaussianImage = gaussianFilter.outputImage else { return nil }
        
        // Apply affects
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = gaussianImage
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value
        colorControlsFilter.saturation = saturationSlider.value
        guard let colorControlsImage = colorControlsFilter.outputImage else { return nil }
        
        // Apply hue adjustment
        let hueFilter = CIFilter.hueAdjust()
        hueFilter.inputImage = colorControlsImage
        hueFilter.angle = hueSlider.value
        
        guard let outputCIImage = hueFilter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage,
                                                      from: CGRect(origin: .zero,
                                                                   size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }

    @IBAction func choosePhoto(_ sender: Any) {
        choosePhoto()
    }
    
    private func choosePhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: Photo library unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    @IBAction func resetValues(_ sender: Any) {
        resetValues()
    }
    
    private func resetValues() {
        guassianBlurSlider.value = 0
        brightnessSlider.value = 0
        contrastSlider.value = 1
        saturationSlider.value = 1
        hueSlider.value = 0
        
        updateViews()
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        savePhoto()
    }
    
    private func savePhoto() {
        guard let originalImage = originalImage else { return }
        
        guard let filteredImage = filterImage(originalImage.flattened) else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetCreationRequest.creationRequestForAsset(from: filteredImage)
                
            }) { success, error in
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
    
    @IBAction func gaussianChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func brightnessChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func hueChanged(_ sender: Any) {
        updateViews()
    }
    
}

extension ImageFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        resetValues()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - Experimental Code

/// This code was supposed to help speed up the processing of the filtering by only applying the filters that was needed for each slider but for some reason it really messed up the image and wouldn't return it to a normal state when I pressed reset. I need to look into this a little more later on.
//    private func filterImageWithAll(_ image: UIImage) {
//        filterImageWithGaussianBlur(image)
//        filterImageWithColorControls(image)
//        filterImageWithHue(image)
//    }
//
//    private func filterImageWithGaussianBlur(_ image: UIImage) {
//        imageLock.lock()
//        defer { imageLock.unlock() }
//
//        guard let cgImage = image.cgImage else { return }
//        let ciImage = CIImage(cgImage: cgImage)
//
//        // Apply gaussian blur
//        let gaussianFilter = CIFilter.gaussianBlur()
//        gaussianFilter.inputImage = ciImage
//        gaussianFilter.radius = guassianBlurSlider.value
//
//        guard let outputCIImage = gaussianFilter.outputImage,
//            let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return }
//
//        let uiImage = UIImage(cgImage: outputCGImage)
//
//        scaledImage = uiImage
//        imageView.image = uiImage
//    }
//
//    private func filterImageWithColorControls(_ image: UIImage) {
//        imageLock.lock()
//        defer { imageLock.unlock() }
//
//        guard let cgImage = image.cgImage else { return }
//        let ciImage = CIImage(cgImage: cgImage)
//
//        // Apply affects
//        let colorControlsFilter = CIFilter.colorControls()
//        colorControlsFilter.inputImage = ciImage
//        colorControlsFilter.brightness = brightnessSlider.value
//        colorControlsFilter.contrast = contrastSlider.value
//        colorControlsFilter.saturation = saturationSlider.value
//
//        guard let outputCIImage = colorControlsFilter.outputImage,
//            let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return }
//
//        let uiImage = UIImage(cgImage: outputCGImage)
//
//        scaledImage = uiImage
//        imageView.image = uiImage
//    }
//
//    private func filterImageWithHue(_ image: UIImage) {
//        imageLock.lock()
//        defer { imageLock.unlock() }
//
//        guard let cgImage = image.cgImage else { return }
//        let ciImage = CIImage(cgImage: cgImage)
//
//        // Apply hue adjustment
//        let hueFilter = CIFilter.hueAdjust()
//        hueFilter.inputImage = ciImage
//        hueFilter.angle = hueSlider.value
//
//        guard let outputCIImage = hueFilter.outputImage,
//            let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return }
//
//        let uiImage = UIImage(cgImage: outputCGImage)
//
//        scaledImage = uiImage
//        imageView.image = uiImage
//    }
