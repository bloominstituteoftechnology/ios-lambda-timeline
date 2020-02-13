//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Photos

enum FilterType {
    case sepia
    case blackAndWhite
    case blur
    case sharpen
    case negative
}

class ImagePostViewController: ShiftableViewController {
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Properties
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var context = CIContext(options: nil)
    var filterType: FilterType!
    
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        titleTextField.delegate = self
        updateViews()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            DispatchQueue.main.async { self.presentImagePickerController() }
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                DispatchQueue.main.async { self.presentImagePickerController() }
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
        @unknown default:
            break
        }
        presentImagePickerController()
    }
    
    @IBAction func sepiaButtonTapped(_ sender: UIButton) {
        originalImage = imageView.image
        valueSlider.minimumValue = 0
        valueSlider.maximumValue = 1
        valueSlider.value = 0
        filterType = .sepia
    }
    
    @IBAction func blackWhiteButtonTapped(_ sender: UIButton) {
        originalImage = imageView.image
        valueLabel.removeFromSuperview()
        valueSlider.removeFromSuperview()
        filterType = .blackAndWhite
        updateImage()
    }
    
    @IBAction func blurButtonTapped(_ sender: UIButton) {
        originalImage = imageView.image
        valueSlider.minimumValue = 0
        valueSlider.maximumValue = 100
        valueSlider.value = 0
        filterType = .blur
    }
    
    @IBAction func sharpenButtonTapped(_ sender: UIButton) {
        originalImage = imageView.image
        valueSlider.minimumValue = 0
        valueSlider.maximumValue = 2
        valueSlider.value = 0.4
        filterType = .sharpen
    }
    
    @IBAction func negativeButtonTapped(_ sender: UIButton) {
        originalImage = imageView.image
        valueLabel.removeFromSuperview()
        valueSlider.removeFromSuperview()
        filterType = .negative
        updateImage()
    }
    
    @IBAction func valueSliderChanged(_ sender: UISlider) {
        updateImage()
    }
    
    func filter(_ image: UIImage, for type: FilterType) -> UIImage? {
        switch type {
        case .sepia:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = valueSlider.value
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        case .blackAndWhite:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        case .blur:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = ciImage
            filter.radius = valueSlider.value
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        case .sharpen:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = ciImage
            filter.sharpness = valueSlider.value
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        case .negative:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.colorInvert()
            filter.inputImage = ciImage
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        }
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            switch self.filterType {
            case .sepia:
                imageView.image = filter(scaledImage, for: .sepia)
            case .blackAndWhite:
                imageView.image = filter(scaledImage, for: .blackAndWhite)
            case .blur:
                imageView.image = filter(scaledImage, for: .blur)
            case .sharpen:
                imageView.image = filter(scaledImage, for: .sharpen)
            case .negative:
                imageView.image = filter(scaledImage, for: .negative)
            case .none:
                break
            }
        } else {
            imageView.image = nil
        }
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
