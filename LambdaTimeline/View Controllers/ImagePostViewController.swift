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
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        originalImage = image
        
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
    
    @IBAction func effectChanged(_ sender: UISegmentedControl) {
        updateFilters()
    }
    
    @IBAction func colorModeChanged(_ sender: UISegmentedControl) {
        updateFilters()
    }
    
    @IBAction func colorChanged(_ sender: UISlider) {
        updateFilters()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    func updateFilters() {
        guard let originalImage = originalImage else { return }
        
        let filteredImage = filterImage(originalImage)
        imageView.image = filteredImage
    }
    
    func filterImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        var ciImage = CIImage(cgImage: cgImage)
        
        if colorSegmentedControl.selectedSegmentIndex == 0 {
            colorControlsFilter.setValue(ciImage, forKey: "inputImage")
            // Saturation is from 0 to 2, which is what the slider is set to
            colorControlsFilter.setValue(colorSlider.value, forKey: "inputSaturation")
            
            if let outputCIImage = colorControlsFilter.outputImage {
                ciImage = outputCIImage
            }
        } else {
            vibranceFilter.setValue(ciImage, forKey: "inputImage")
            // Vibrance is from -1 to 1, so subtract 1 from the slider value
            vibranceFilter.setValue(colorSlider.value - 1, forKey: "inputAmount")
            
            if let outputCIImage = vibranceFilter.outputImage {
                ciImage = outputCIImage
            }
        }
        
        effect: if effectSegmentedControl.selectedSegmentIndex > 0 {
            let effectFilter: CIFilter
            
            switch effectSegmentedControl.selectedSegmentIndex {
            case 2:
                effectFilter = monoFilter
            case 3:
                effectFilter = noirFilter
            default:
                break effect
            }
            
            effectFilter.setValue(ciImage, forKey: "inputImage")
            if let outputCIImage = effectFilter.outputImage {
                ciImage = outputCIImage
            }
        }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(ciImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    private var originalImage: UIImage?
    
    private let context = CIContext(options: nil)
    private let colorControlsFilter = CIFilter(name: "CIColorControls")!
    private let vibranceFilter = CIFilter(name: "CIVibrance")!
    private let monoFilter = CIFilter(name: "CIPhotoEffectMono")!
    private let noirFilter = CIFilter(name: "CIPhotoEffectNoir")!
    private let sepiaFilter = CIFilter(name: "CISepiaTone")!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var effectSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colorSlider: UISlider!
}

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
