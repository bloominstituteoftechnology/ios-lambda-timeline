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

enum FilterType {
    case BackWhite
    case Soften
    case Blur
    case Brightening
    case Vintage
}

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
    var context = CIContext(options: nil)
    var filterType: FilterType!
    private var original: UIImage? {
        didSet {
            guard original != nil else {return}
            
            updateImage()

        }
    }
    
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBAction func blurChanged(_ sender: Any) {
        original = imageView.image
        filterType = .Blur
        updateImage()
    }
    @IBAction func blackAndWhiteTapped(_ sender: UIButton) {
        original = imageView.image
        filterType = .BackWhite
        updateImage()
    }
    @IBAction func vintageTapped(_ sender: Any) {
        original = imageView.image
        filterType = .Vintage
        updateImage()
    }
    @IBAction func softenTapped(_ sender: Any) {
        original = imageView.image
        filterType = .Soften
        updateImage()
    }
    @IBAction func brightenTapped(_ sender: Any) {
        original = imageView.image
        filterType = .Brightening
        updateImage()
    }
    
    func filter(_ image: UIImage, for filter: FilterType) -> UIImage? {
        switch filter {
        case .BackWhite:
            guard let cgImage = image.cgImage else {return nil}
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter(name: "CIPhotoEffectTonal")!
            filter.setValue(ciImage, forKey: "inputImage")
            guard let outputCI = filter.outputImage else { return nil }
            guard let outputCG = context.createCGImage(outputCI, from: CGRect(origin: .zero, size: image.size)) else {return nil}
            return UIImage(cgImage: outputCG)
        case .Blur:
            guard let cgImage = image.cgImage else {return nil}
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter(name: "CIGaussianBlur")!
            filter.setValue(ciImage, forKey: "inputImage")
            filter.setValue(blurSlider.value, forKey: "inputRadius")
            guard let outputCI = filter.outputImage else { return nil }
            guard let outputCG = context.createCGImage(outputCI, from: CGRect(origin: .zero, size: image.size)) else {return nil}
            return UIImage(cgImage: outputCG)
        case .Brightening:
            guard let cgImage = image.cgImage else {return nil}
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter(name: "CIHighlightShadowAdjust")!
            filter.setValue(ciImage, forKey: "inputImage")
            guard let outputCI = filter.outputImage else { return nil }
            guard let outputCG = context.createCGImage(outputCI, from: CGRect(origin: .zero, size: image.size)) else {return nil}
            return UIImage(cgImage: outputCG)
        case .Soften:
            guard let cgImage = image.cgImage else {return nil}
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter(name: "CIBloom")!
            filter.setValue(ciImage, forKey: "inputImage")
            guard let outputCI = filter.outputImage else { return nil }
            guard let outputCG = context.createCGImage(outputCI, from: CGRect(origin: .zero, size: image.size)) else {return nil}
            return UIImage(cgImage: outputCG)
        case .Vintage:
            guard let cgImage = image.cgImage else {return nil}
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter(name: "CIPhotoEffectInstant")!
            filter.setValue(ciImage, forKey: "inputImage")
            guard let outputCI = filter.outputImage else { return nil }
            guard let outputCG = context.createCGImage(outputCI, from: CGRect(origin: .zero, size: image.size)) else {return nil}
            return UIImage(cgImage: outputCG)
        default:
            break
        }
    }
    
    private func updateImage() {
        if let original = original {

            switch self.filterType {
            case .BackWhite:
                imageView.image = filter(original, for: .BackWhite)
            case .Blur:
                imageView.image = filter(original, for: .Blur)
            case .Brightening:
                imageView.image = filter(original, for: .Brightening)
            case .Soften:
                imageView.image = filter(original, for: .Soften)
            case .Vintage:
                imageView.image = filter(original, for: .Vintage)
            default:
                break
            }
        } else {
            imageView.image = nil
        }
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
