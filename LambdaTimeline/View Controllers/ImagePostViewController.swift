//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    var originalImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    private let blurFilter = CIFilter(name: "CIGaussianBlur")
    private let gammaFilter = CIFilter(name: "CIGammaAdjust")
    private let invertFilter = CIFilter(name: "CIColorInvert")
    private let monoFilter = CIFilter(name: "CIPhotoEffectMono")
    private let fadeFilter = CIFilter(name: "CIPhotoEffectFade")
    private let context = CIContext(options: nil)
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sliderLabel1: UILabel!
    @IBOutlet weak var sliderLabel2: UILabel!
    
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
       
    }
    
    func updateImage() {
        if let originalImage = originalImage {
            //based on selected segment index change type of filter.
                
                switch filterSegmentedControl.selectedSegmentIndex {
            case 0:
                //blur filter
                imageView.image = blurImage(image: originalImage)
            case 1:
                //gamma filter
                imageView.image = gammaImage(image: originalImage)
            case 2:
                //invert filter
                imageView.image = invertImage(image: originalImage)
            case 3:
                //pixel filter
                imageView.image = monoImage(image: originalImage)
            default:
                // Fade
                imageView.image = fadeImage(image: originalImage)
            }
        } else {
            imageView.image = nil
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        updateImage()
    }
    
    
    @IBAction func slider1ValueChanged(_ sender: Any) {
    }
    
    @IBAction func slider2ValueChanged(_ sender: Any) {
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
        
//        switch filterSegmentedControl.selectedSegmentIndex {
//        case 0:
//            sliderLabel1.isHidden = false
//            sliderLabel1.text = "Blur Radius"
//            slider1.isHidden = false
//            sliderLabel2.isHidden = true
//            slider2.isHidden = true
//        case 1:
//            sliderLabel1.isHidden = false
//            sliderLabel1.text = "Power"
//            slider1.isHidden = false
//            slider2.isHidden = true
//            sliderLabel2.isHidden = true
//        case 2:
//            sliderLabel1.isHidden = true
//            slider1.isHidden = true
//            sliderLabel2.isHidden = true
//            slider2.isHidden = true
//        case 3:
//            slider1.isHidden = false
//            sliderLabel1.isHidden = false
//            sliderLabel1.text = "Center"
//            slider2.isHidden = false
//            sliderLabel2.isHidden = false
//            sliderLabel2.text = "Scale"
//
//        default:
//            sliderLabel1.isHidden = true
//            slider1.isHidden = true
//            sliderLabel2.isHidden = true
//            slider2.isHidden = true
//        }
       
    }
    
    private func invertImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)

        invertFilter?.setValue(ciImage, forKey: "inputImage")

        guard let outputCIImage = invertFilter?.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func fadeImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        fadeFilter?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = fadeFilter?.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func gammaImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        gammaFilter?.setValue(ciImage, forKey: "inputImage")
        gammaFilter?.setValue(0.75, forKey: "inputPower")
        guard let outputCIImage = gammaFilter?.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func blurImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        blurFilter?.setValue(ciImage, forKey: "inputImage")
        blurFilter?.setValue(10.00, forKey: "inputRadius")
        guard let outputCIImage = blurFilter?.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func monoImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        monoFilter?.setValue(ciImage, forKey: "inputImage")
        guard let outputCIImage = monoFilter?.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
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
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
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
