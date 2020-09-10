//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

class ImagePostViewController: ShiftableViewController {
    
    @IBOutlet weak var hueSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {
                scaledImage = nil
                return
            }

            var scaledSize = imageView.bounds.size
            let scale = imageView.contentScaleFactor

            scaledSize.width *= scale
            scaledSize.height *= scale

            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }

            scaledImage = CIImage(image: scaledUIImage)
        }
    }

    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }

    private let context = CIContext()
    private let colorControlsFilter = CIFilter.colorControls()
    private let blurFilter = CIFilter.gaussianBlur()
    private let hueAdjustment = CIFilter.hueAdjust()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let image = imageView.image,
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }

        postController.createImagePost(with: title, image: image, ratio: image.ratio)
        
        navigationController?.popViewController(animated: true)
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
        default:
            break
        }
        presentImagePickerController()
    }
    
    @IBAction func addFilter(_ sender: Any) {
        
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }

    private func image(byFiltering inputImage: CIImage) -> UIImage? {
        colorControlsFilter.inputImage = inputImage
        colorControlsFilter.saturation = saturationSlider.value
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value

        blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
        blurFilter.radius = blurSlider.value

        hueAdjustment.inputImage = blurFilter.outputImage
        hueAdjustment.angle = hueSlider.value

        guard let outputImage = hueAdjustment.outputImage else { return nil }

        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }

        return UIImage(cgImage: renderedCGImage)
    }

    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }

    @IBAction func saturationChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func contrastChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func blurChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func hueChanged(_ sender: UISlider) {
        updateImage()
    }

}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        if let images = info[.editedImage] as? UIImage {
            originalImage = images
        } else if let images  = info[.originalImage] as? UIImage {
            originalImage = images
        }
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
