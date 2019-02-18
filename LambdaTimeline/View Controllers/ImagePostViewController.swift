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
    
    // MARK: - Properties
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var originalImage: UIImage? {
        didSet { updateImageView() }
    }
    var filter: CIFilter? {
        didSet { setupFilterUI(); updateImageView(); print(filter?.attributes ?? "") }
    }
    
    private let context = CIContext(options: nil)
    private var sliders: [FilterSlider] = []
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var controlStackView: UIStackView!
    @IBOutlet weak var addFilterButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    // MARK: - UI Actions
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
    
    @IBAction func addFilter(_ sender: Any) {
        originalImage = imageView.image
        presentFilterAlert()
    }
    
    // MARK: - Utility Methods
    private func updateViews() {
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                updateAddFilterButton()
                return
        }
        
        title = post?.title
        setImageViewHeight(with: image.ratio)
        originalImage = image
        chooseImageButton.setTitle("", for: [])
    }
    
    private func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        view.layoutSubviews()
    }
    
    private func updateAddFilterButton() {
        addFilterButton.isHidden = imageView.image == nil
    }
    
    @objc private func updateImageView() {
        guard let image = originalImage else { return }
        
        imageView.image = applyFilter(to: image)

        updateAddFilterButton()
    }
    
    private func applyFilter(to image: UIImage) -> UIImage {
        guard let filter = filter else { return image }
        
        let inputImage: CIImage
        
        if let ciImage = image.ciImage {
            inputImage = ciImage
        } else if let cgImage = image.cgImage {
            inputImage = CIImage(cgImage: cgImage)
        } else {
            return image
        }
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        for slider in sliders {
            filter.setValue(slider.value, forKey: slider.attributeName)
        }
        
        guard let outputImage = filter.outputImage else { return image }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func setupFilterUI() {
        for slider in sliders {
            controlStackView.removeArrangedSubview(slider.view)
            slider.view.removeFromSuperview()
        }
        
        guard let filter = filter else { return }
        
        sliders = filter.attributes.compactMap { (key, value) -> FilterSlider? in
            return FilterSlider(name: key, attributes: value)
            }.sorted {
                $0.displayName < $1.displayName
        }
        
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)
        
        for filterSlider in sliders {
            controlStackView.addArrangedSubview(filterSlider.view)
            
            let slider = filterSlider.slider
            
            let equalWidth = slider.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor)
            equalWidth.isActive = true
            
            slider.addTarget(self, action: #selector(updateImageView), for: .valueChanged)
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
    
    private func presentFilterAlert() {
        let alert = UIAlertController(title: "Add Filter", message: "Which kind of filter do you want to add?", preferredStyle: .actionSheet)
        
        let hueAction = UIAlertAction(title: "Hue", style: .default) { (_) in
            self.filter = CIFilter(name: "CIHueAdjust")
        }
        alert.addAction(hueAction)
        
        let BCSAction = UIAlertAction(title: "Brightness/Contrast/Saturation", style: .default) { (_) in
            self.filter = CIFilter(name: "CIColorControls")
        }
        alert.addAction(BCSAction)
        
        let blurAction = UIAlertAction(title: "Blur", style: .default) { (_) in
            self.filter = CIFilter(name: "CIDiscBlur")
        }
        alert.addAction(blurAction)
        
        let crystallizeAction = UIAlertAction(title: "Crystallize", style: .default) { (_) in
            self.filter = CIFilter(name: "CICrystallize")
        }
        alert.addAction(crystallizeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        
        if filter != nil {
            let removeFiltersAction = UIAlertAction(title: "Remove Filter", style: .destructive) { (_) in
                self.filter = nil
            }
            alert.addAction(removeFiltersAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UI Image Picker Controller Delegate
extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        originalImage = image
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
