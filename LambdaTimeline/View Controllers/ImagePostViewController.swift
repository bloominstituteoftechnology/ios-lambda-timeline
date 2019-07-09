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
    
    //filter properties
    private let controlFilter = CIFilter(name: "CIColorControls") //the name must match so refer to the documentation
    private let blurFilter = CIFilter(name: "CIMotionBlur")
    private let context = CIContext(options: nil)
    var originalImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var angleSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    @IBAction func saturationValuChanged(_ sender: UISlider) {
        updateViews()
    }
    @IBAction func brightnessValueChanged(_ sender: UISlider) {
        updateViews()
    }
    @IBAction func contrastValueChanged(_ sender: UISlider) {
        updateViews()
    }
    @IBAction func raidiusValueChanged(_ sender: UISlider) {
        updateViews()
    }
    @IBAction func angleValueChanged(_ sender: UISlider) {
        updateViews()
    }
    
    private func image(byFiltering image: UIImage) -> UIImage {
        //this is where we add the filters to the image
        //we have to go from a CGImage to a CIImage
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        //set the filter properties
        controlFilter?.setValue(ciImage, forKey: "inputImage") //this key must match so refer to documentation
        
        //can either type in the string name or the kCIInputKeys
        controlFilter?.setValue(saturationSlider.value, forKey: "inputSaturation") //again we are getting the key from the documentation
        controlFilter?.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey) //this is an example of where we use the key to avoid stringly typed code
        controlFilter?.setValue(contrastSlider.value, forKey: kCIInputContrastKey)
        
        //motionBlurFilter
        blurFilter?.setValue(controlFilter?.outputImage, forKey: "inputImage")
        blurFilter?.setValue(radiusSlider.value, forKey: kCIInputRadiusKey)
        blurFilter?.setValue(angleSlider.value, forKey: kCIInputAngleKey)
        
        guard let outputCIImage = blurFilter?.outputImage else { return image }
        
        //render the image - actually apply our filters
        //go back from cIImage to cGIimage
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        
        //then we have to go from a cGImage to a UIImage
        return UIImage(cgImage: outputCGImage)
        
    }
   
    
    func updateViews() {
        
        if let originalImage = originalImage {
            imageView.image = image(byFiltering: originalImage)
            title = post?.title
            setImageViewHeight(with: originalImage.ratio)
            chooseImageButton.setTitle("", for: [])
        } else {
            imageView.image = nil
            title = "New Post"
        }
        
        
//        guard let imageData = imageData,
//            let image = UIImage(data: imageData) else {
//                return
//        }
        
//        imageView.image = image
//        let myImage = image(byFiltering: image)
//        imageView.image = image(byFiltering: image)
        
    }
    
//    func updateImage(){
//        guard let data = imageData else { print("Error right here too"); return }
//        guard let image = UIImage(data: data) else { print("problem right here"); return }
//        let myImage = image(byFiltering: image)
//        if let currentImage = originalImage {
//            imageView.image = image(byFiltering: currentImage)
//        }
//    }
    
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
    var imageData: Data? {
        didSet {
//            print("imageData set and triggered.")
//            updateImage()
        }
    }
  
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        chooseImageButton.setTitle("", for: [])
//
//        picker.dismiss(animated: true, completion: nil)
//
//        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
//
////        imageView.image = image
//        originalImage = image
//        setImageViewHeight(with: image.ratio)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

