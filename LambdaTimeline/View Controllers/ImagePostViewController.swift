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
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    private let context = CIContext(options:nil)
    private let colorControlFilter = CIFilter(name: "CIColorControls")!
    private let colorInvertFilter = CIFilter(name: "CIColorInvert")!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var filterSelector: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var typeLabel: UILabel!
    
    var brightnessValue: Float = 0
    var contrastValue: Float = 0.5
    var saturationValue: Float = 0.5
    var isColorInverted = false
    var bloomIntensity: Float = 0.5
    var imageWithoutColorChange: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
        updateSlider()
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
    
    private func updateSlider() {
        switch filterSelector.selectedSegmentIndex {
        case 0:
            slider.value = brightnessValue
            slider.minimumValue = -1
            slider.maximumValue = 1
            slider.isHidden = false
            toggleSwitch.isHidden = true
            typeLabel.text = "Adjust brightness"
        case 1:
            slider.value = contrastValue
            slider.minimumValue = 0.25
            slider.maximumValue = 4
            slider.isHidden = false
            toggleSwitch.isHidden = true
            typeLabel.text = "Adjust contrast"
        case 2:
            slider.value = saturationValue
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.isHidden = false
            toggleSwitch.isHidden = true
            typeLabel.text = "Adjust saturation"
        case 3:
            slider.isHidden = true
            toggleSwitch.isHidden = false
            typeLabel.text = "Invert color"
        case 4:
            slider.value = 0
            slider.minimumValue = -1
            slider.maximumValue = 1
            slider.isHidden = false
            toggleSwitch.isHidden = true
            typeLabel.text = "Smooth edges"
        default:
            break
        }
    }
    
    private func colorControlFilterImage(_ image: UIImage) -> UIImage {
        //let CIImage = image.ciImage //nil, not going to work
        guard let cgImage = image.cgImage else { fatalError("No image available for filtering")}
        let ciImage = CIImage(cgImage: cgImage)
        
        colorControlFilter.setValue(ciImage, forKey: kCIInputImageKey)
        colorControlFilter.setValue(brightnessValue, forKey: kCIInputBrightnessKey)
        colorControlFilter.setValue(contrastValue, forKey: kCIInputContrastKey)
        colorControlFilter.setValue(saturationValue, forKey: kCIInputSaturationKey)
        
        guard let outputCIImage = colorControlFilter.outputImage else { fatalError("cant make out put CI image") }
        //outputCIImage.cgImage // nil with a CIImage
        
        //render the image
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { fatalError("cant make out put CG image")}
        return UIImage(cgImage: outputCGImage)
    }
    
    private func colorInvertFilterImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { fatalError("No image available for filtering")}
        let ciImage = CIImage(cgImage: cgImage)
        
        colorInvertFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputCIImage = colorInvertFilter.outputImage else { fatalError("cant make out put ci image with color invert filter")}
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { fatalError("cant make out put CG image with color invert filter")}
        return UIImage(cgImage: outputCGImage)
    }
    
    @IBAction func toggleChanged(_ sender: Any) {
        if filterSelector.selectedSegmentIndex == 3 {
            if let image = imageView.image {
                let colorInvertedImage = colorInvertFilterImage(image)
                imageView.image = colorInvertedImage
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        switch filterSelector.selectedSegmentIndex {
        case 0:
            brightnessValue = slider.value
            print("change brightness")
        case 1:
            contrastValue = slider.value
            print("change contrast")
        case 2:
            saturationValue = slider.value
            print("change saturation")
        default:
            return
        }
        if let image = imageWithoutColorChange {
            let filteredImage = colorControlFilterImage(image)
            imageView.image = filteredImage
        }
    }
    
    
    @IBAction func filterSelectorChanged(_ sender: Any) {
        updateSlider()
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
    

}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        imageWithoutColorChange = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
