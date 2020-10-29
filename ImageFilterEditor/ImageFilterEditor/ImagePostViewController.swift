//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Rob Vance on 10/28/20.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var vignetteSlider: UISlider!
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    // Mark: - Properties -
    
    private var orignalImage: UIImage? {
        didSet {
            guard let orignalImage = orignalImage else {
                scaledImage = nil
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = imageView.contentScaleFactor
            
            scaledSize.width *= scale
            scaledSize.height *= scale
            guard let scaledUIImage = orignalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    private var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    private let context = CIContext()
    private let colorControlsFilter = CIFilter.colorControls()
    private let blurFilter = CIFilter.gaussianBlur()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        orignalImage = imageView.image
    }
    
    
    private func image(byFiltering image: CIImage) -> UIImage? {
        let inputImage = image
        
        colorControlsFilter.inputImage = inputImage
        colorControlsFilter.saturation = saturationSlider.value
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value
        
        // blur filter
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
        blurFilter.radius = blurSlider.value
        
        // vignette filter
        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = blurFilter.outputImage?.clampedToExtent()
        vignetteFilter.intensity = vignetteSlider.value
        vignetteFilter.radius = vignetteSlider.value
        
        guard let outputImage = blurFilter.outputImage else { return nil }
        
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        
        return UIImage(cgImage: renderedCGImage)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    // MARK: - IBActions -
    
    @IBAction func choosePhotoTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Photo library is not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    @IBAction func savePhotoTapped(_ sender: Any) {
        
    }
    
    // MARK: - Sliders -
    @IBAction func brightnessChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func blurChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func vignetteChanged(_ sender: Any) {
        updateImage()
    }
    
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            orignalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            orignalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
