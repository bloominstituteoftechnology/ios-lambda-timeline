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
    
    // MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var topSlider: UISlider!
    @IBOutlet weak var middleSlider: UISlider!
    @IBOutlet weak var bottomSlider: UISlider!
    
    // MARK: - Properties
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            print("Size: \(scaledSize)")
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    private var filter = CIFilter(name: "CIColorControls")!
    private var context = CIContext(options: nil)
    private var imagePosition = CGPoint.zero
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    // MARK: - Updates
    
    func updateViews() {
        
        setColorControlsSliderValues()
        setColorControls()
        
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
    
    private func filterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        setFilter()
        
        guard let outputCIImage = filter.outputImage else { return image }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func setFilter() {
        switch filter.name {
        case "CIVignette": setVignette()
        default: setColorControls()
        }
    }
    
    private func setColorControls() {
        filter.setValue(topSlider.value, forKey: kCIInputBrightnessKey)
        filter.setValue(middleSlider.value, forKey: kCIInputContrastKey)
        filter.setValue(bottomSlider.value, forKey: kCIInputSaturationKey)
    }
    
    private func setVignette() {
        filter.setValue(topSlider.value, forKey: kCIInputIntensityKey)
        filter.setValue(middleSlider.value, forKey: kCIInputRadiusKey)
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
    
    // MARK: - Actions
    
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
    
    @IBAction func changeFilterTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            filter = CIFilter(name: "CIVignette")!
            setVignetteSliderValues()
        case 2:
            filter = CIFilter(name: "CIColorControls")!
            setColorControlsSliderValues()
        case 3:
            filter = CIFilter(name: "CIColorControls")!
            setColorControlsSliderValues()
        case 4:
            filter = CIFilter(name: "CIColorControls")!
            setColorControlsSliderValues()
        default:
            filter = CIFilter(name: "CIColorControls")!
            setColorControlsSliderValues()
        }
    }
    
    private func setColorControlsSliderValues() {
        UIView.animate(withDuration: 0.3) {
            self.topLabel.text = "Brightness"
            self.middleLabel.text = "Contrast"
            self.bottomLabel.text = "Saturation"
            
            self.topLabel.isHidden = false
            self.middleLabel.isHidden = false
            self.bottomLabel.isHidden = false
            
            self.topSlider.isHidden = false
            self.middleSlider.isHidden = false
            self.bottomSlider.isHidden = false
            
            self.topSlider.value = 0
            self.topSlider.minimumValue = -1
            self.topSlider.maximumValue = 1
            
            self.middleSlider.value = 1
            self.middleSlider.minimumValue = 0.25
            self.middleSlider.maximumValue = 4
            
            self.bottomSlider.value = 1
            self.bottomSlider.minimumValue = 0
            self.bottomSlider.maximumValue = 2
        }
    }
    
    private func setVignetteSliderValues() {
        
        UIView.animate(withDuration: 0.3) {
            self.topLabel.text = "Intensity"
            self.middleLabel.text = "Radius"
            
            self.topLabel.isHidden = false
            self.middleLabel.isHidden = false
            self.bottomLabel.isHidden = true
            
            self.topSlider.isHidden = false
            self.middleSlider.isHidden = false
            self.bottomSlider.isHidden = true
            
            self.topSlider.value = 0
            self.topSlider.minimumValue = -1
            self.topSlider.maximumValue = 1
            
            self.middleSlider.value =  1
            self.middleSlider.minimumValue = 0
            self.middleSlider.maximumValue = 2
        }
    }
    
    @IBAction func topSliderChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func middleSliderChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func bottomSliderChanged(_ sender: Any) {
        updateImage()
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil
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
            
        @unknown default:
            fatalError("Add new case for PHPhotoLibrary.authorizationStatus()")
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
        
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
