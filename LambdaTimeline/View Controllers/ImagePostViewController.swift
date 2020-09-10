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

    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!


    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var vignetteSlider: UISlider!
    @IBOutlet weak var whitePointSlider: UISlider!
    @IBOutlet weak var falseColorSlider: UISlider!
    @IBOutlet weak var monochromaticSlider: UISlider!


    // MARK: - Properties

    let postController = PostController.shared
    var post: Post?
    var imageData: Data?
    private let context = CIContext()

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

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        originalImage = imageView.image
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

    // MARK: - Functions

    func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }

    private func image(byFiltering image: CIImage) -> UIImage? {
        let inputImage = image

        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = image
        blurFilter.radius = blurSlider.value


        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = blurFilter.outputImage?.clampedToExtent()
        vignetteFilter.intensity = vignetteSlider.value * 5
        vignetteFilter.radius = vignetteSlider.value * 50

        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.inputImage = vignetteFilter.outputImage?.clampedToExtent()
        sepiaFilter.intensity = whitePointSlider.value

        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = sepiaFilter.outputImage?.clampedToExtent()
        sharpenFilter.sharpness = falseColorSlider.value

        let monochromaticFilter = CIFilter.colorMonochrome()
        monochromaticFilter.inputImage = sepiaFilter.outputImage?.clampedToExtent()
        monochromaticFilter.intensity = monochromaticSlider.value

        guard let outputImage = monochromaticFilter.outputImage else { return nil }

        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }

        return UIImage(cgImage: renderedCGImage)
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {

        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio

        view.layoutSubviews()
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
        
        guard let image = imageView.image,
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }

        postController.createImagePost(with: title, image: image, ratio: image.ratio, audioURL: nil)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - IBActions

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

    
    @IBAction func blurSliderUpdated(_ sender: Any) {
        updateImage()
    }

    @IBAction func vignetteSliderUpdated(_ sender: Any) {
        updateImage()
    }

    @IBAction func sepiaSliderUpdated(_ sender: Any) {
        updateImage()
    }

    @IBAction func sharpenSliderUpdated(_ sender: Any) {
        updateImage()
    }

    @IBAction func monochromaticSliderUpdated(_ sender: Any) {
        updateImage()
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])

        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }

        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
