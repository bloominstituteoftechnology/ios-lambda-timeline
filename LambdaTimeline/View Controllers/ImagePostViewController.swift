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
        originalImage = image
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
    
    @IBAction func instantFilterButtonTapped(_ sender: Any) {
        
        guard let cgImage = imageView.image?.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIPhotoEffectInstant")
        filter?.setValue(ciImage, forKey: "inputImage")
        
        guard let ciOutputImage = filter?.outputImage,
        let outputCGImage = context.createCGImage(ciOutputImage, from: ciOutputImage.extent)
        else { return}
        
        let outputImage = UIImage(cgImage: outputCGImage)
        self.imageData = outputImage.pngData()
        updateViews()
    }
    
    @IBAction func monoFilterButtonTapped(_ sender: Any) {
        guard let cgImage = imageView.image?.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIPhotoEffectMono")
        filter?.setValue(ciImage, forKey: "inputImage")
        
        guard let ciOutputImage = filter?.outputImage,
            let outputCGImage = context.createCGImage(ciOutputImage, from: ciOutputImage.extent)
            else { return}
        
        let outputImage = UIImage(cgImage: outputCGImage)
        self.imageData = outputImage.pngData()
        updateViews()
    }
    
    @IBAction func processFilterButtonTapped(_ sender: Any) {
        guard let cgImage = imageView.image?.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIPhotoEffectProcess")
        filter?.setValue(ciImage, forKey: "inputImage")
        
        guard let ciOutputImage = filter?.outputImage,
            let outputCGImage = context.createCGImage(ciOutputImage, from: ciOutputImage.extent)
            else { return}
        
        let outputImage = UIImage(cgImage: outputCGImage)
        self.imageData = outputImage.pngData()
        updateViews()
        
    }
    
    @IBAction func blurSliderValueChanged(_ sender: Any) {
        
        guard let image = originalImage,
        let cgImage = image.cgImage
        else { return }
        let ciImage = CIImage(cgImage: cgImage)

        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: "inputImage")
        filter?.setValue(blurSlider.value, forKey: "inputRadius")

        guard let ciOutputImage = filter?.outputImage,
            let outputCGImage = context.createCGImage(ciOutputImage, from: ciOutputImage.extent)
            else { return}

        imageView.image = UIImage(cgImage: outputCGImage)
    }
    
    @IBAction func distortionSliderValueChanged(_ sender: Any) {
       
        guard let image = originalImage,
            let cgImage = image.cgImage
            else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIHoleDistortion")
        filter?.setValue(ciImage, forKey: "inputImage")
        filter?.setValue(CIVector(x: imageView.center.x, y: imageView.center.y), forKey: "inputCenter")
        filter?.setValue(distortionSlider.value, forKey: "inputRadius")
        
        guard let ciOutputImage = filter?.outputImage,
            let outputCGImage = context.createCGImage(ciOutputImage, from: ciOutputImage.extent)
            else { return}
        
        imageView.image = UIImage(cgImage: outputCGImage)
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var originalImage: UIImage?
    let context = CIContext(options: nil)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var distortionSlider: UISlider!
    
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
