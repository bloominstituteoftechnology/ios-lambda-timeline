//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

enum Filters {
    case posterize
    case circularScreen
    case edgeWork
}

class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
        let filter = CIFilter.colorMatrix()
        print(filter)
        print(filter.attributes)
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
    
    
    var isPosterized: Bool = false
    let context = CIContext(options: nil)
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var filters: Filters = .posterize
    
    var scaledImage: UIImage? {
        didSet {
            
        }
    }
    // MARK: Actions
    
    
    @IBAction func luminanceRadiusChanged(_ sender: Any) {
        updateLuminanceImage()
    }
    
    @IBAction func luminanceChanged(_ sender: Any) {
        updateLuminanceImage()
    }
    
    @IBAction func radiusChanged(_ sender: Any) {
        updateSepiaToneImage()
    }
    
    @IBAction func evChanged(_ sender: Any) {
        updateExposureAdjustImage()
    }
    
    @IBAction func widthChanged(_ sender: Any) {
        updateCircularScreenImage()
    }
    
    @IBAction func sharpnessChanged(_ sender: Any) {
        updateCircularScreenImage()

    }
    
    @IBAction func posterizeChanged(_ sender: Any) {
        updatePosterizedImage()

    }
    
    func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = posterizeImage(scaledImage)
            imageView.image = circularScreenImage(scaledImage)
            imageView.image = exposureAdjustImage(scaledImage)
        }
    }
    
    func exposureAdjustImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)

        let filter = CIFilter.exposureAdjust()
        filter.inputImage = ciImage
        filter.ev = evSlider.value
        
       
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func circularScreenImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.circularScreen()
        filter.inputImage = ciImage
        filter.sharpness = sharpnessSlider.value
        filter.width = widthSlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func sharpenLuminanceImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = ciImage
        filter.sharpness = luminanceSlider.value
        filter.radius = luminanceRadiusSlider.value
        
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func sepiaToneImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.sepiaTone()
        filter.inputImage = ciImage
        filter.intensity = intensitySlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func posterizeImage(_ image: UIImage) -> UIImage? {
        
        // UIImage > CGImage > CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.colorPosterize()
        filter.inputImage = ciImage
        filter.levels = posterizeSlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
            
        // Render the image (apply the filter to the image) i.e. baking the cookies in the over
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
            // CIImage > CGImage > UIImage
        return UIImage(cgImage: outputCGImage)
    }
    
    
    func updateExposureAdjustImage() {
        if let scaledImage = scaledImage {
            imageView.image = exposureAdjustImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    func updateSharpenLuminanceImage() {
        if let scaledImage = scaledImage {
            imageView.image = sharpenLuminanceImage(scaledImage)
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
    
    func updatePosterizedImage() {
        if let scaledImage = scaledImage {
            imageView.image = posterizeImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    func updateCircularScreenImage() {
        if let scaledImage = scaledImage {
            imageView.image = circularScreenImage(scaledImage)
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
    
    var originalImage: UIImage? {
        didSet {
            imageView.image = originalImage?.flattened
            
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width * scale,
                                height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    
    
    
    
    @IBOutlet weak var luminanceRadiusSlider: UISlider!
    @IBOutlet weak var luminanceSlider: UISlider!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var evSlider: UISlider!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var sharpnessSlider: UISlider!
    @IBOutlet weak var posterizeSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
