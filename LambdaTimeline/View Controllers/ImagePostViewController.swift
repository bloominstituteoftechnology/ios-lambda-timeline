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
    
    let blur = CIFilter(name: "CIDiscBlur")!
    let hueAdjust = CIFilter(name: "CIHueAdjust")
    let filter = CIFilter(name: "CILineOverlay")
    let context = CIContext(options: nil)
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    var scaledImage: UIImage? {
        didSet {
            updateImageView()
        }
    }
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            let originalSizeOfImage = imageView.bounds.size
            let deviceScreenSize = UIScreen.main.scale
            
            let scaledSize = CGSize(width: originalSizeOfImage.width * deviceScreenSize, height: originalSizeOfImage.height * deviceScreenSize)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    var originalImage2: UIImage? {
        didSet {
            updateImage2View()
        }
    }
    
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var hueAdjustLabel: UILabel!
    @IBOutlet weak var hueAdjustSlider: UISlider!
    @IBOutlet weak var noiseLevelLabel: UILabel!
    @IBOutlet weak var noiseLevelSlider: UISlider!
    @IBOutlet weak var sharpnessLabel: UILabel!
    @IBOutlet weak var sharpnessSlider: UISlider!
    @IBOutlet weak var edgeIntensityLabel: UILabel!
    @IBOutlet weak var edgeIntensitySlider: UISlider!
    @IBOutlet weak var thresholdLabel: UILabel!
    @IBOutlet weak var thresholdSlider: UISlider!
    @IBOutlet weak var contrastLabel: UILabel!
    @IBOutlet weak var contrastSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    @IBAction func blurSliderAction(_ sender: UISlider) {
        updateImageView()
    }
    @IBAction func hueAdjustSliderAction(_ sender: UISlider) {
        updateImageView()
    }
    @IBAction func noiseLevelSliderAction(_ sender: UISlider) {
        updateImage2View()
    }
    @IBAction func sharpnessSliderAction(_ sender: UISlider) {
        updateImage2View()
    }
    @IBAction func edgeIntensitySliderAction(_ sender: UISlider) {
        updateImage2View()
    }
    @IBAction func thresholdSliderAction(_ sender: UISlider) {
        updateImage2View()
    }
    @IBAction func contrastSliderAction(_ sender: UISlider) {
        updateImage2View()
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
    
    func updateImageView() {
        if let scaledImage = scaledImage {
            imageView.image = image2(byFiltering: scaledImage)
        }
    }
    
    func updateImage2View() {
        if let originalImage = originalImage2 {
            imageView.image = image2(byFiltering: originalImage)
        }
    }
    
    private func image(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        blur.setValue(ciImage, forKey: "inputImage")
        blur.setValue(blurSlider.value, forKey: "inputRadius")
        
        guard let blurOutputCIImage = blur.outputImage else { return image }
        
        hueAdjust?.setValue(blurOutputCIImage, forKey: "inputImage")
        hueAdjust?.setValue(hueAdjustSlider.value, forKey: "inputAngle")
        
        guard let outputCIImage = hueAdjust?.outputImage else { return image }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func image2(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        filter?.setValue(ciImage, forKey: "inputImage")
        filter?.setValue(noiseLevelSlider.value, forKey: "inputNRNoiseLevel")
        filter?.setValue(sharpnessSlider.value, forKey: "inputNRSharpness")
        filter?.setValue(edgeIntensitySlider.value, forKey: "inputThreshold")
        filter?.setValue(contrastSlider.value, forKey: "inputContrast")
        
        guard let outputCIImage = filter?.outputImage else { return image }
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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

//extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        chooseImageButton.setTitle("", for: [])
//
//        picker.dismiss(animated: true, completion: nil)
//
//        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
//
//        imageView.image = image
//
//        setImageViewHeight(with: image.ratio)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}
extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
//        imageView.image = image
        originalImage2 = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
