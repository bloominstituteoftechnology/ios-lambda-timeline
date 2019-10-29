//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class ImagePostViewController: ShiftableViewController {
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    private let context = CIContext(options: nil)
    private let photoEffectInstantFilter = CIFilter(name: "CIPhotoEffectInstant")!
    private let photoEffectNoirFilter = CIFilter(name: "CIPhotoEffectNoir")!
    private let vibranceFilter = CIFilter(name: "CIVibrance")!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var instantFilterSwitch: UISwitch!
    @IBOutlet weak var noirFilterSwitch: UISwitch!
    @IBOutlet weak var vibranceSlider: UISlider!
    
    var image: UIImage?
    
    var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setImageViewHeight(with: 1.0)
        originalImage = imageView.image
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
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        view.layoutSubviews()
    }
    
    
    @IBAction func instantFilter(_ sender: UISwitch) {
        if instantFilterSwitch.isOn == true {
            if let image = imageView.image {
                 imageView.image = photoEffectInstantFilterImage(image)
            }
        } else {
            if imageView.image != nil {
                 imageView.image = originalImage
            }
        }
    }
    
    @IBAction func noirFilter(_ sender: UISwitch) {
        if noirFilterSwitch.isOn == true {
            if let image = imageView.image {
                 imageView.image = photoEffectNoirFilterImage(image)
            }
        } else {
            if imageView.image != nil {
                 imageView.image = originalImage
            }
        }
    }
    
    @IBAction func vibranceFilter(_ sender: UISlider) {
        if let image = imageView.image {
             imageView.image = vibranceFilterImage(image)
        }
    }
    
    
    private func photoEffectInstantFilterImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        photoEffectInstantFilter.setValue(ciImage, forKey: "inputImage")
        guard let outputCIImage = photoEffectInstantFilter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func photoEffectNoirFilterImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        photoEffectNoirFilter.setValue(ciImage, forKey: "inputImage")
        guard let outputCIImage = photoEffectNoirFilter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func vibranceFilterImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        vibranceFilter.setValue(ciImage, forKey: "inputImage")
        vibranceFilter.setValue(vibranceSlider.value, forKey: "inputAmount")
        guard let outputCIImage = vibranceFilter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        chooseImageButton.setTitle("", for: [])
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        originalImage = image
        imageView.image = image
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
