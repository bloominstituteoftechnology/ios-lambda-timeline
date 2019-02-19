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

class ImagePostViewController: ShiftableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        filterName = pickerData[row]
        
        return pickerData[row]
    }
    func setPicker() -> String {
        if let filterName = filterName, filterName.count > 0 {
            return filterName
            
        } else {
            return "CIColorControls"
        }
    }
  
    let shiftableViewController = ShiftableViewController()
    let filterChooserViewController = FilterChooserViewController()
    var filterName: String?
   // let filter = CIFilter(name: self.setPicker())
    private let context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        didSet {
            updateImageView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let filter = CIFilter(name: self.setPicker()) else { return }
        setImageViewHeight(with: 1.0)
      // updateImageView()
        updateViews()
        filterPicker.dataSource = self
        filterPicker.delegate = self
        configurationSlider(brightnessSliderOutlet, from: filter.attributes[kCIInputBrightnessKey])
        configurationSlider(contrastSliderOutlet, from: filter.attributes[kCIInputContrastKey])
        configurationSlider(saturationSliderOutlet, from: filter.attributes[kCIInputSaturationKey])
        
       
    }
    
        @IBOutlet weak var brightnessSliderOutlet: UISlider!
        @IBOutlet weak var contrastSliderOutlet: UISlider!
        @IBOutlet weak var saturationSliderOutlet: UISlider!
    
    @IBOutlet weak var filterPicker: UIPickerView!
    
    var pickerData: [String] = [
//        "CIColorControls",
//        "CICategoryBlur",
//        "CICategoryColorAdjustment",
//        "CICategoryColorEffect",
//        "CICategoryCompositeOperation",
//        "CICategoryDistortionEffect",
//        "CICategoryGenerator",
//        "CICategoryGeometryAdjustment",
//        "CICategoryGradient",
//        "CICategoryHalftoneEffect"
//        ]
    kCICategoryBuiltIn,
    kCICategoryColorAdjustment,
    kCICategoryColorEffect,
    kCICategoryDistortionEffect,
    kCICategoryGeometryAdjustment,
    kCICategoryCompositeOperation,
    kCICategoryHalftoneEffect,
    kCICategoryTransition,
    kCICategoryTileEffect,
    kCICategoryGenerator,
    kCICategoryReduction,
    kCICategoryGradient,
    kCICategoryStylize,
    kCICategorySharpen,
    kCICategoryBlur,
    kCICategoryVideo,
    kCICategoryStillImage,
    kCICategoryInterlaced,
    kCICategoryNonSquarePixels,
    kCICategoryHighDynamicRange
       ]
    @IBAction func savePhoto(_ sender: Any) {
    }
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
      //  let name = CIFilter.filterNames(inCategory: setPicker())
        let filter = CIFilter(name: setPicker())!
        print(setPicker())
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
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
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
//}

//extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
