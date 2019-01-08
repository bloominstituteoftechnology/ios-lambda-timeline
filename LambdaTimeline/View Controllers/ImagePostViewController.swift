//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import ImageIO

class ImagePostViewController: ShiftableViewController {
    

    

    @IBOutlet weak var changeSwitch: UISwitch!
    
    @IBAction func SwitchOn(_ sender: Any) {
        updateImage()
       
        
    }
    
    
    
    
    
    
    @IBAction func hue(_ sender: UISlider) {
        updateImage()
        
        
    }
    
    
    @IBAction func blur(_ sender: UISlider) {
        updateImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        
        updateViews()
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
    
    
    var originalImage: UIImage? {
        didSet {
            updateImage()
            
//            guard let originalImage = originalImage else { return }
//
//            // Height and width
//            var scaledSize = imageView.bounds.size
//
//            // 1x, 2x, or 3x
//            let scale = UIScreen.main.scale
//
//            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
//
//            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    
    
    
    private func updateImage() {
        
        guard let originalImage = originalImage else { return }
        imageView.image = image(byFiltering: originalImage)
        
        if changeSwitch.isOn {
        imageView.image =  switchBW(image: originalImage)
           
        }
        
    }
    
    
    private func image(byFiltering image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Set the values of the filter's parameters
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(hueSlider.value, forKey: kCIInputAngleKey)
        filterBlur.setValue(filter.outputImage, forKey: kCIInputImageKey)
        filterBlur.setValue(blurSlider.value, forKey: kCIInputRadiusKey)
       // filterBW.setValue(ciImage, forKey: "inputImage")
        
        
        
        // The metadata to be processed. NOT the actual filtered image
        guard let outputCIImage = filterBlur.outputImage else { return image}
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        

        
        return UIImage(cgImage: outputCGImage)
    }
    
   
    func switchBW(image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image}
        
        let ciImage = CIImage(cgImage: cgImage)
        
        
        filterBW.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = filterBW.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    
    }
    
    
    private let context = CIContext(options: nil)
    private let filter = CIFilter(name: "CIHueAdjust")!
    private let filterBlur = CIFilter(name: "CIDiscBlur")!
    private let filterBW = CIFilter(name:"CIPhotoEffectNoir")!
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
   
    @IBOutlet weak var blurSlider: UISlider!
    
    @IBOutlet weak var hueSlider: UISlider!
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
        
        setImageViewHeight(with: image.ratio)
       originalImage = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
   
}

//extension UIImage {
//    func imageByScaling(toSize size: CGSize) -> UIImage? {
//        guard let data = pngData(),
//            let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
//                return nil
//        }
//
//        let options: [CFString: Any] = [
//            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) / 2.0,
//            kCGImageSourceCreateThumbnailFromImageAlways: true
//        ]
//
//        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary).flatMap { UIImage(cgImage: $0) }
//    }
//}

