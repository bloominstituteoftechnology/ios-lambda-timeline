//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

enum Filters: String {
    case CIHueAdjust
}

class ImagePostViewController: ShiftableViewController {
    
    private let context = CIContext(options: nil)
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            
            // 1x 2x 3x (400 points * 3x = 1200 pixels)
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
            
            guard let scaledImage = scaledImage else { return }
            
            // set min max for zoom blur slider
            xValueSlider.minimumValue = 0
            xValueSlider.maximumValue = Float(scaledImage.size.width)
            xValueSlider.value = xValueSlider.maximumValue / 2
            
            yValueSlider.minimumValue = 0
            yValueSlider.maximumValue = Float(scaledImage.size.height)
            yValueSlider.value = yValueSlider.maximumValue / 2
            
            // set min max for hue slider
            hueSlider.minimumValue = -3.14
            hueSlider.maximumValue = 3.14
            hueSlider.value = 0
            
            // reset zoom blur value
            zoomBlurValueSlider.value = 0
            
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateFilters()
        }
    }
    
    // Hue Properties
    @IBOutlet weak var hueValueLabel: UILabel!
    @IBOutlet weak var hueSlider: UISlider!
    
    private let hueFilter = CIFilter(name: Filters.CIHueAdjust.rawValue)!
    
    // Zoom Blur Properties
    @IBOutlet weak var xValueLabel: UILabel!
    @IBOutlet weak var yValueLabel: UILabel!
    @IBOutlet weak var zoomBlurValueLabel: UILabel!
    @IBOutlet weak var xValueSlider: UISlider!
    @IBOutlet weak var yValueSlider: UISlider!
    @IBOutlet weak var zoomBlurValueSlider: UISlider!
    
    // Comic Effect Property
    @IBOutlet weak var comicEffectSwitch: UISwitch!
    
    
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
    
    private func updateFilters() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func filterImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Hue
        hueFilter.setValue(ciImage, forKey: "inputImage")
        hueFilter.setValue(hueSlider.value, forKey: "inputAngle")
        
        // Zoom Blur
        let center = CIVector(x: CGFloat(xValueSlider!.value), y: CGFloat(yValueSlider!.value))
        let zoomBlurImage = hueFilter.outputImage!.applyingFilter("CIZoomBlur", parameters: ["inputCenter" : center, "inputAmount": zoomBlurValueSlider.value])
        
        // Comic Effect
        var comicImage: CIImage
        if comicEffectSwitch.isOn {
            comicImage = zoomBlurImage.applyingFilter("CIComicEffect")
        } else {
            comicImage = zoomBlurImage
        }
        
        
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(comicImage, from: bounds) else { return image }
        
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
        
        guard let originalImage = originalImage, let imageData = filterImage(originalImage).jpegData(compressionQuality: 0.1),
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
    
    @IBAction func hueValueChanged(_ sender: UISlider) {
        updateFilters()
        hueValueLabel.text = String(format: "%.2f", hueSlider.value)
    }
    @IBAction func zoomBlurXValueChanged(_ sender: Any) {
        updateFilters()
        xValueLabel.text = "x: \(xValueSlider.value)"
    }
    @IBAction func zoomBlurYValueChanged(_ sender: Any) {
        updateFilters()
        yValueLabel.text = "y: \(yValueSlider.value)"
    }
    @IBAction func zoomBlurAmountValueChanged(_ sender: Any) {
        updateFilters()
        zoomBlurValueLabel.text = String(format: "%.2f", zoomBlurValueSlider.value)
    }
    @IBAction func comicEffectValueChanged(_ sender: Any) {
        updateFilters()
    }
    
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
