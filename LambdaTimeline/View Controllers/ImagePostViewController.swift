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

        if let originalImage = originalImage {
            imageView.image = image(byFiltering: originalImage)
            title = post?.title
            chooseImageButton.setTitle("", for: [])
            setImageViewHeight(with: originalImage.ratio)
            zoomBlurSlider.isEnabled = true
            zoomXSlider.isEnabled = true
        } else {
            imageView.image = nil
            title = "New Post"
        }


    }

    private func image(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image}

        let ciImage = CIImage(cgImage: cgImage)

        blurZoomFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurZoomFilter?.setValue(zoomBlurSlider.value, forKey: "inputAmount")


        circularFilter?.setValue(blurZoomFilter?.outputImage, forKey: kCIInputImageKey)
        circularFilter?.setValue(zoomXSlider.value, forKey: "inputWidth")
        

        guard let outputCIImage = circularFilter?.outputImage else { return image }


        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image}

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
            break
        }
        presentImagePickerController()
    }


    @IBAction func zoomBlurChanged(_ sender: Any) {
        updateViews()
    }

    @IBAction func zoomXChanged(_ sender: Any) {
        updateViews()
    }
    @IBAction func zoomYChanged(_ sender: Any) {
        updateViews()
    }

    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var originalImage: UIImage? {
        didSet {
            updateViews()
        }
    }

    private let blurZoomFilter = CIFilter(name: "CIZoomBlur")
    private let circularFilter = CIFilter(name: "CICircularScreen")

    private let context = CIContext(options: nil)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var zoomBlurSlider: UISlider!
    @IBOutlet weak var zoomXSlider: UISlider!
    @IBOutlet weak var zoomYSlider: UISlider!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }


        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
