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
        buildSliders()
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
    
    private func buildSliders() {
        for slider in sliders {
            masterStack.removeArrangedSubview(slider.view)
            slider.view.removeFromSuperview()
        }
        
        sliders = (filter?.attributes.compactMap { (key, value) -> SliderInput? in
            return SliderInput(name: key, attributes: value)
            }.sorted {
                $0.displayName < $1.displayName
            })!
        
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)
        
        for (offset, sliderInput) in sliders.enumerated() {
            masterStack.insertArrangedSubview(sliderInput.view, at: offset)
            
            let slider = sliderInput.slider
            
            let equalWidth = slider.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor)
            equalWidth.isActive = true
            
            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        }
        
    }
    
    private func updateImageView() {
        guard let image = originalImage else { return }
        imageView?.image = applyFilter(to: image)
    }
    
    private func applyFilter(to image: UIImage) -> UIImage {
        
        let inputImage: CIImage
        
        if let ciImage = image.ciImage {
            inputImage = ciImage
        } else if let cgImage = image.cgImage {
            inputImage = CIImage(cgImage: cgImage)
        } else {
            //FIXME: Not sure what's going on if we get to this point... should probably change code to prevent something like this from happening.
            return image
        }
        
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        
        for sliderAttribute in sliders {
            let value = sliderAttribute.slider.value
            filter?.setValue(value, forKey: sliderAttribute.attributeName)
        }
        
        guard let outputImage = filter?.outputImage else {
            return image
        }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        updateImageView()
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
    
    
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    private var originalImage: UIImage? {
        didSet {
            updateImageView()
        }
    }
    private var filter = CIFilter(name: "CIVortexDistortion") {
        didSet {
            buildSliders()
            updateImageView()
        }
    }
    private var sliders = Array<SliderInput>()
    private let context = CIContext(options: nil)
    
    @IBOutlet weak var masterStack: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
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
