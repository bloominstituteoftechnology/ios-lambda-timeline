//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage.CIFilterBuiltins

class ImagePostViewController: ShiftableViewController {
    
    // MARK: - Outlets and Variables
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var vibranceSlider: UISlider!
    @IBOutlet weak var exposureSlider: UISlider!
    @IBOutlet weak var sepiaSlider: UISlider!
    @IBOutlet weak var radialGradientSlider: UISlider!
    @IBOutlet weak var pixelSlider: UISlider!
    @IBOutlet weak var filtersStackView: UIStackView!
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    var originalImage: UIImage?
    
    private let context = CIContext(options: nil)
    private let vibranceFilter = CIFilter.vibrance()
    private let exposureFilter = CIFilter.exposureAdjust()
    private let sepiaFilter = CIFilter.sepiaTone()
    private let radialGradientFilter = CIFilter.radialGradient()
    private let pixelFilter = CIFilter.pixellate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
        
        // hide the filters 
        self.filtersStackView.isHidden = true
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
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        var tempImage: CIImage = inputImage

        tempImage = self.vibrance(for: tempImage)
        tempImage = self.sepia(for: tempImage)
        tempImage = self.exposure(for: tempImage)
        tempImage = self.radialGradient(for: tempImage)
        tempImage = self.pixel(for: tempImage)
        
        guard let renderedImage = context.createCGImage(tempImage, from: tempImage.extent) else { return UIImage(ciImage: inputImage) }
        
        return UIImage(cgImage: renderedImage)
    }
    
    private func updateImage() {
        if let originalImage = originalImage, let image = CIImage(image: originalImage) {
            imageView.image = self.image(byFiltering: image)
        }
    }
    
    // MARK: - Filters
    
    private func vibrance(for image: CIImage) -> CIImage {
        vibranceFilter.inputImage = image
        vibranceFilter.amount = self.vibranceSlider.value
        return vibranceFilter.outputImage ?? image
    }
    
    private func sepia(for image: CIImage) -> CIImage {
        sepiaFilter.inputImage = image
        sepiaFilter.intensity = sepiaSlider.value
        return sepiaFilter.outputImage ?? image
    }
    
    private func exposure(for image: CIImage) -> CIImage {
        exposureFilter.inputImage = image
        exposureFilter.ev = self.exposureSlider.value
        return exposureFilter.outputImage ?? image
    }

    private func radialGradient(for image: CIImage) -> CIImage {
        if self.radialGradientSlider.value > 0.0 {
            let imageExtent = image.extent
            let center = CGPoint(x: imageExtent.width/2.0, y: imageExtent.height/2.0)
            let smallerDimension = min(imageExtent.width, imageExtent.height)
            let largerDimension = max(imageExtent.width, imageExtent.height)
            
            // first filter
            radialGradientFilter.center = center
            radialGradientFilter.radius0 = Float(smallerDimension / 2.0) * (self.radialGradientSlider.value / 2)
            radialGradientFilter.radius1 = Float(largerDimension / 2.0) / (self.radialGradientSlider.value / 2)
            let radialGradientImage = radialGradientFilter.outputImage!
            
            // second filter
            return image.applyingFilter("CIBlendWithMask", parameters: ["inputMaskImage" : radialGradientImage])
        } else {
            return image
        }
    }
    
    private func pixel(for image: CIImage) -> CIImage {
        if self.pixelSlider.value > 0.0 {
            pixelFilter.inputImage = image
            pixelFilter.scale = self.pixelSlider.value * 12
            return pixelFilter.outputImage ?? image
        } else {
            return image
        }
    }
    
    // MARK: - Actions
    
    @IBAction func vibrancePressed(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func exposurePressed(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func sepiaPressed(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func radialGradientPressed(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func pixelPressed(_ sender: Any) {
        self.updateImage()
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
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
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
        self.originalImage = image
        
        setImageViewHeight(with: image.ratio)
        
        // show all filters
        self.filtersStackView.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
