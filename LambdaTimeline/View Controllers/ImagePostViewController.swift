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
        chooseImageButton.setTitle("", for: [])
        addFilter()
    }
    
    func addFilter() {
        if let imageData = imageData,
            let chromeImage = UIImage(data: imageData) {
            imageView.image = chromeFilterImage(chromeImage)
        } else if let imageData = imageData,
            let fadeImage = UIImage(data: imageData) {
            imageView.image = fadeFilterImage(fadeImage)
        } else if let imageData = imageData,
            let instantImage = UIImage(data: imageData) {
            imageView.image = instantFilterImage(instantImage)
        } else if let imageData = imageData,
            let noirImage = UIImage(data: imageData) {
            imageView.image = noirFilterImage(noirImage)
        } else if let imageData = imageData,
            let processImage = UIImage(data: imageData) {
            imageView.image = processFilterImage(processImage)
        } else if let imageData = imageData,
            let comicImage = UIImage(data: imageData) {
            imageView.image = comicFilterImage(comicImage)
        } else if let imageData = imageData,
            let vignetteImage = UIImage(data: imageData) {
            imageView.image = vignetteFilterImage(vignetteImage)
        } else if let imageData = imageData,
            let hexImage = UIImage(data: imageData) {
            imageView.image = hexFilterImage(hexImage)
        }
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
            fatalError()
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        view.layoutSubviews()
    }
    
    private func chromeFilterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        chromeFilter?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = chromeFilter?.outputImage else { return image }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func fadeFilterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        fadeFilter?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = fadeFilter?.outputImage else { return image }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func instantFilterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        instantFilter?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = instantFilter?.outputImage else { return image }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func noirFilterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        noirFilter?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = noirFilter?.outputImage else { return image }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func processFilterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        processFilter?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = processFilter?.outputImage else { return image }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func comicFilterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        comicFilter?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = comicFilter?.outputImage else { return image }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func vignetteFilterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        vignetteFilter?.setValue(ciImage, forKey: "inputImage")
        vignetteFilter?.setValue(0.8, forKey: kCIInputRadiusKey)
        vignetteFilter?.setValue(0.5, forKey: kCIInputIntensityKey)
        
        guard let outputCIImage = vignetteFilter?.outputImage else { return image }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func hexFilterImage(_ image: UIImage) -> UIImage {
        
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        hexFilter?.setValue(ciImage, forKey: "inputImage")
        hexFilter?.setValue(8.0, forKey: kCIInputScaleKey)
        hexFilter?.setValue([150, 150], forKey: kCIInputCenterKey)
        
        guard let outputCIImage = hexFilter?.outputImage else { return image }
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    private let context = CIContext(options: nil)
    private let chromeFilter = CIFilter(name: "CIPhotoEffectChrome")
    private let fadeFilter = CIFilter(name: "CIPhotoEffectFade")
    private let instantFilter = CIFilter(name: "CIPhotoEffectInstant")
    private let noirFilter = CIFilter(name: "CIPhotoEffectNoir")
    private let processFilter = CIFilter(name: "CIPhotoEffectProcess")
    private let comicFilter = CIFilter(name: "CIComicEffect")
    private let vignetteFilter = CIFilter(name: "CIVignette")
    private let hexFilter = CIFilter(name: "CIDepthOfField")
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    // Filters
    @IBAction func chromeFilter(_ sender: UIButton) {
        addFilter()
    }
    
    @IBAction func fadeFilter(_ sender: UIButton) {
        addFilter()
    }
    
    @IBAction func instantFilter(_ sender: UIButton) {
        addFilter()
    }
    
    @IBAction func noirFilter(_ sender: UIButton) {
        addFilter()
    }
    
    @IBAction func processFilter(_ sender: UIButton) {
        addFilter()
    }
    
    @IBAction func comicFilter(_ sender: UIButton) {
        addFilter()
    }
    
    @IBAction func vignetteFilter(_ sender: UIButton) {
        addFilter()
    }
    
    @IBAction func hexFilter(_ sender: UIButton) {
        addFilter()
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
