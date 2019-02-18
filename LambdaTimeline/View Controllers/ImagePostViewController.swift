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
    var filter: CIFilter? {
        didSet { setupFilterUI() }
    }
    
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
        presentFilterAlert()
    }
    
    // MARK: - Utility Methods
    private func updateViews() {
        defer { updateAddFilterButton() }
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
    
    private func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        view.layoutSubviews()
    }
    
    private func updateAddFilterButton() {
        addFilterButton.isHidden = imageView.image == nil
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
            
//            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
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
        
        let BCSAction = UIAlertAction(title: "Brightness/Contrast/Saturation", style: .default) { (_) in
            self.filter = CIFilter(name: "CIColorControls")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(BCSAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UI Image Picker Controller Delegate
extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = image
        updateAddFilterButton()
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
