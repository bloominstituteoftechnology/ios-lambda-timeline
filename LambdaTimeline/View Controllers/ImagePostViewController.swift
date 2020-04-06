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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
 
        if let scaledImage = scaledImage {
                imageView.image = filterImage(scaledImage)
            } else {
                imageView.image = nil
            title = "New Post"
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
            
        @unknown default:
            print("FatalError")
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
    
    private var context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = UIImage(data: imageData) else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    // Filter Outlets
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var blurAngleSlider: UISlider!
    @IBOutlet weak var blurRadiusSlider: UISlider!
    @IBOutlet weak var kaleidoscopeAngleSlider: UISlider!
    @IBOutlet weak var kaleidoscopeCountSlider: UISlider!
    
    // MARK: Slider events
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateViews()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        updateViews()
    }

    @IBAction func blurAngleChanged(_ sender: Any) {
           updateViews()
       }
    
    @IBAction func blurRadiusChanged(_ sender: Any) {
           updateViews()
       }
    
    @IBAction func kaleidoscopeAngleChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func kaleidoscopeCountChanged(_ sender: Any) {
        updateViews()
    }
    
    // MARK: - Private Methods
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let filterCIImage = kaleidoscopeFilter(motionBlurFilter(colorControlFilter(cgImage)))
        
        guard let outputImage = context.createCGImage(filterCIImage,
                                                      from: CGRect(origin: .zero,
                                                                   size: image.size)) else {
                                                                    return nil
        }
        return UIImage(cgImage: outputImage)
    }
    
    private func colorControlFilter(_ image: CIImage) -> CIImage {
        
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = convertToCIImage(image)
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value
        colorControlsFilter.saturation = saturationSlider.value
        
        guard let outputCIImage = colorControlsFilter.outputImage else { return nil }
        return outputCIImage
    }
    
    private func motionBlurFilter(_ image: CIImage) -> CIImage {
        let motionBlurFilter = CIFilter.motionBlur()
        motionBlurFilter.inputImage = convertToCIImage(image)
        motionBlurFilter.angle = blurAngleSlider.value
        motionBlurFilter.radius = blurRadiusSlider.value
        
        guard let outputCIImage = motionBlurFilter.outputImage else { return nil }
        return outputCIImage
    }
    
    private func kaleidoscopeFilter(_ image: CIImage) -> CIImage {
        guard let originalImage = originalImage else { return CIImage() }
        
        let kaleidoscopeFilter = CIFilter.kaleidoscope()
        kaleidoscopeFilter.inputImage = image
        kaleidoscopeFilter.center = CGPoint(x: originalImage.size.width / 2,
                                            y: originalImage.size.height / 2)
        kaleidoscopeFilter.angle = kaleidoscopeAngleSlider.value
        kaleidoscopeFilter.count = kaleidoscopeCountSlider.value
        
        guard let outputCIImage = kaleidoscopeFilter.outputImage else { return nil }
        return outputCIImage
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
