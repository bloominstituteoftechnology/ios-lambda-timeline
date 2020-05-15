//
//  ImageFilterViewController.swift
//  ImageFilterEditor
//
//  Created by denis cedeno on 5/7/20.
//  Copyright © 2020 DenCedeno Co. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImageFilterViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var bloomSlider: UISlider!
    
    @IBAction func chooseImage(_ sender: Any) {
        presentImagePickerController()
    }
    @IBAction func postImage(_ sender: Any) {
        savePhoto()
    }
    @IBAction func brightnessChanged(_ sender: Any) {
        updateImage()
    }
    @IBAction func blurChanged(_ sender: Any) {
        updateImage()
    }
    @IBAction func saturationChanged(_ sender: Any) {
        updateImage()
    }
    @IBAction func contrastChanged(_ sender: Any) {
        updateImage()
    }
    @IBAction func bloomChanged(_ sender: Any) {
        updateImage()
    }
    
    var photoArray: [FilteredImage] = []
    var photo: FilteredImage?
    private let photoController = FilteredImageController()
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            var scaledSize = imageView.bounds.size
            let scale: CGFloat = UIScreen.main.scale
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
    private let blurFilter = CIFilter.gaussianBlur()
    private let bloomFilter = CIFilter.bloom()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        originalImage = imageView.image
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        colorControlsFilter.inputImage = inputImage
        colorControlsFilter.saturation = saturationSlider.value
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value
        
        blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
        blurFilter.radius = blurSlider.value
        guard let blurImage = blurFilter.outputImage else { return originalImage! }
        
        bloomFilter.inputImage = blurImage
        bloomFilter.intensity = 1
        bloomFilter.radius = bloomSlider.value
        
        guard let outputImage = bloomFilter.outputImage else { return originalImage! }
        
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
        
        return UIImage(cgImage: renderedImage)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    // MARK: - Private Methods
    @objc private func addImage() {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    return
                }
                self.presentImagePickerController()
            }
        default:
            break
        }
    }
    
    private func savePhoto() {
        guard let originalImage = originalImage?.flattened,
              let comments = commentTextField.text,
              let ciImage = CIImage(image: originalImage) else { return }
        let lattitude = 51.5549
        let longitude = -0.108436
        let processedImage = self.image(byFiltering: ciImage)
        guard let imageData = processedImage.pngData() else {return}
        
        photoArray.append(FilteredImage(image: imageData, comments: comments, lattitude: lattitude, longitide: longitude))
        
        photoController.appendFilteredImage(images: imageData, comments: comments, lattitude: lattitude, longitude: longitude)
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
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
    
    private func updateViews() {
        guard let photo = photo else {
            title = "Add Image"
            return
        }
        title = photo.comments
        imageView.image = UIImage(data: photo.image!)
        commentTextField.text = photo.comments
    }
    
    private func viewPhotoLocation() {
        guard let originalImage = originalImage?.flattened,
              let comments = commentTextField.text,
              let ciImage = CIImage(image: originalImage) else { return }
        
        let lattitude = 51.5549
        let longitude = -0.108436
        
        let processedImage = self.image(byFiltering: ciImage)
        guard let imageData = processedImage.pngData() else {return}
        
        photoArray.append(FilteredImage(image: imageData, comments: comments, lattitude: lattitude, longitide: longitude))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageLocationSegue" {
            guard let mapVC = segue.destination as? PhotoMapViewController else { return }
            viewPhotoLocation()
            mapVC.photos = self.photoArray
        }
    }
    
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func presentSuccessfulSaveAlert() {
        let alert = UIAlertController(title: "Photo Saved!", message: "The photo has been saved to your Photo Library!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        navigationController?.popViewController(animated: true)
        present(alert, animated: true, completion: nil)
    }
}


extension ImageFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
