//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
import CoreImage
import UIKit
import Photos

class ImagePostViewController: ShiftableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   
  
   
    
  
    private let context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        didSet {
            updateImageView()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hideElements()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideElements()
        let filter = CIFilter(name: "CIColorControls")!
        let filterZoom = CIFilter(name: "CIZoomBlur")!
        let filterPixel = CIFilter(name: "CIPixellate")!
        let filterMask = CIFilter(name: "CIUnsharpMask")!
        setImageViewHeight(with: 1.0)
      // updateImageView()
        updateViews()
        
        configurationSlider(brightnessSliderOutlet, from: filter.attributes[kCIInputBrightnessKey]!)
        configurationSlider(contrastSliderOutlet, from: filter.attributes[kCIInputContrastKey]!)
        configurationSlider(saturationSliderOutlet, from: filter.attributes[kCIInputSaturationKey]!)
        configurationSlider(zoomSliderOutlet, from: filterZoom.attributes[kCIInputAmountKey]!)
        configurationSlider(pixelSliderOutlet, from: filterPixel.attributes[kCIInputScaleKey]!)
        configurationSlider(maskSliderOutlet, from: filterMask.attributes[kCIInputRadiusKey]!)
        configurationSlider(intesitysSiderOutlet, from: filterMask.attributes[kCIInputIntensityKey]!)
       
    }
    func hideElements() {
        if imageView.image == nil {
            elementStackView.isHidden = true
        } else {
            elementStackView.isHidden = false
        }
    }
    
    @IBOutlet weak var elementStackView: UIStackView!
    @IBOutlet weak var brightnessSliderOutlet: UISlider!
    @IBOutlet weak var contrastSliderOutlet: UISlider!
    @IBOutlet weak var saturationSliderOutlet: UISlider!
    @IBOutlet weak var zoomSliderOutlet: UISlider!
    @IBOutlet weak var pixelSliderOutlet: UISlider!
    @IBOutlet weak var maskSliderOutlet: UISlider!
    @IBOutlet weak var intesitysSiderOutlet: UISlider!
    
    
    
    @IBAction func sliderChange(_ sender: Any) {
        updateImageView()
        
    }
    
    
    
    
    private func configurationSlider(_ slider: UISlider, from attributes: Any) {
        
        let attrs = attributes as? [String: Any] ?? [:]
        
        if let min = attrs[kCIAttributeSliderMin] as? Float,
            let max = attrs[kCIAttributeSliderMax] as? Float,
            let value = attrs[kCIAttributeDefault] as? Float {
            
            slider.minimumValue = min
            slider.maximumValue = max
            slider.value = value
            
            
        } else {
            slider.minimumValue = 1
            slider.maximumValue = 1
            slider.value = 0.5
        }
        
    }
    
    private func updateImageView() {
        //updateViews()
        guard let image = originalImage else { return}
        imageView.image = applyFilter(to: image)
        
    }
    
    private func applyFilter(to image: UIImage) -> UIImage {
    
        let filter = CIFilter(name: "CIColorControls")!
        let filterZoom = CIFilter(name: "CIZoomBlur")!
        let filterPixel = CIFilter(name: "CIPixellate")!
        let filterMask = CIFilter(name: "CIUnsharpMask")!
        let inputImage: CIImage
        if let ciImage = image.ciImage {
            inputImage = ciImage
        } else if let cgImage = image.cgImage {
            inputImage = CIImage(cgImage: cgImage)
        }else {
            //
            return image
        }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(brightnessSliderOutlet.value, forKey: kCIInputBrightnessKey)
        filter.setValue(contrastSliderOutlet.value, forKey: kCIInputContrastKey)
        filter.setValue(saturationSliderOutlet.value, forKey: kCIInputSaturationKey)
        
        
        guard let outputImage = filter.outputImage else {
            return image
        }
        
        filterZoom.setValue(outputImage, forKey: kCIInputImageKey)
        filterZoom.setValue(zoomSliderOutlet.value/19, forKey: kCIInputAmountKey)
        
        guard let outputZoomImage = filterZoom.outputImage else {
            return image
        }
        
        filterPixel.setValue(outputZoomImage, forKey: kCIInputImageKey)
        filterPixel.setValue(pixelSliderOutlet.value, forKey: kCIInputScaleKey)
        
        guard let outputFilteredImage = filterPixel.outputImage else {
            return image
        }
        
        filterMask.setValue(outputFilteredImage, forKey: kCIInputImageKey)
        filterMask.setValue(maskSliderOutlet.value, forKey: kCIInputRadiusKey)
        filterMask.setValue(intesitysSiderOutlet.value, forKey: kCIInputIntensityKey)
            guard let outputFinalImage = filterMask.outputImage else {
                return image
            }
        
       
    
        guard let cgImage = context.createCGImage(outputFinalImage, from: outputFinalImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func updateViews() {

        guard let imageData = imageData,
            let originalImage = UIImage(data: imageData) else {
                title = "New Post"
                return
        }

        title = post?.title

        setImageViewHeight(with: originalImage.ratio)

        imageView.image = applyFilter(to: originalImage)

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
       updateImageView()
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

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        originalImage = info[.originalImage] as? UIImage
        imageView.image = originalImage
       // setImageViewHeight(with: originalImage.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
