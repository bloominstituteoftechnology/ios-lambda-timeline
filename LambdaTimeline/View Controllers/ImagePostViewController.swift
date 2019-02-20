//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
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

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    // MARK: - Properties
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!

    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var sepiaSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var filterStackList: UIStackView!
    
    private let filter = CIFilter(name: "CIColorControls")!
    private let sepiaFilter = CIFilter(name:"CISepiaTone")!
    private let blurFilter = CIFilter(name:"CIBoxBlur")!
    private let context = CIContext(options: nil)
    private var originalImage: UIImage? {
        didSet {
            updateImageView()
        }
    }
    
    @IBAction func silderChanged(_ sender: Any) {
        updateImageView()
    }
    
    private func updateImageView() {
        // Check to see if we have an image first...
        guard let image = originalImage else { return }
        imageView?.image = applyFilter(to: image)
    }
    
    // The delay on filter is greatly reduce when using this method, but
    // the stack view flash appears after the rest of the view controller displays...
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        toShowOrNotToShow()
//    }
    
    // There is a huge delay with the filter when using this method.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        toShowOrNotToShow()
    }
    
    
    func toShowOrNotToShow() {
        if imageView.image == nil {
            filterStackList.isHidden = true
        } else {
            filterStackList.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toShowOrNotToShow()
        configureSlider(brightnessSlider, from: filter.attributes[kCIInputBrightnessKey])
        configureSlider(contrastSlider, from: filter.attributes[kCIInputContrastKey])
        configureSlider(saturationSlider, from: filter.attributes[kCIInputSaturationKey])
        configureSlider(sepiaSlider, from: sepiaFilter.attributes[kCIInputIntensityKey])
        configureSlider(blurSlider, from: blurFilter.attributes[kCIInputRadiusKey])
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
    
    
    private func configureSlider(_ slider: UISlider, from attributes: Any?) {
        let attrs = attributes as? [String: Any] ?? [:]
        if let min = attrs[kCIAttributeSliderMin] as? Float,
            let max = attrs[kCIAttributeSliderMax] as? Float,
            let value = attrs[kCIAttributeDefault] as? Float {
            slider.minimumValue = min
            slider.maximumValue = max
            slider.value = value
        } else {
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.value = 0.5
        }
    }
    
    private func applyFilter(to image: UIImage) -> UIImage {
        let inputImage: CIImage
        if let ciImage = image.ciImage {
            inputImage = ciImage
        } else if let cgImage = image.cgImage {
            inputImage = CIImage(cgImage: cgImage)
        } else {
            //🤷‍♂️
            return image
        }
        blurFilter.setValue(inputImage, forKey: kCIInputImageKey)
        blurFilter.setValue(blurSlider.value, forKey: kCIInputRadiusKey)
        guard let otherOtherOutputImage = blurFilter.outputImage else {
            return image
        }
        
        filter.setValue(otherOtherOutputImage, forKey: kCIInputImageKey)
        filter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
        filter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)
        filter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)
        guard let otherOutputImage = filter.outputImage else {
            return image
        }
        
        
        sepiaFilter.setValue(otherOutputImage, forKey: kCIInputImageKey)
        print(sepiaFilter.attributes)
        sepiaFilter.setValue(sepiaSlider.value, forKey: kCIInputIntensityKey)
        guard let outputImage = sepiaFilter.outputImage else {
            return image
        }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        return UIImage(cgImage: cgImage)
    }
}



/*
guard let outputImage = filter.outputImage else {
    guard let otherOutputImage = sepiaFilter.outputImage else {
        return image
    }
    //continue
    return image
}
*/
