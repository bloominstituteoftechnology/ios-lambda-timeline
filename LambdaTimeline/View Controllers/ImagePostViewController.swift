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

    enum FilterType: String, CaseIterable {
        case motionBlur = "Motion Blur"
        case edges = "Edges"
        case posterize = "Posterize"
        case vintage = "Vintage"
        case invert = "Invert Colors"
    }

    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var context = CIContext(options: nil)

    var originalImage: UIImage? {
        didSet { scaledImage = scaleImage(originalImage) }
    }
    var scaledImage: UIImage? {
        didSet { filterPreviewImage() }
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var chooseImageButton: UIButton!
    @IBOutlet private weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var postButton: UIBarButtonItem!

    // MARK: - Filter Views

    @IBOutlet private weak var motionBlurButton: UIButton!
    @IBOutlet private weak var edgesButton: UIButton!
    @IBOutlet private weak var posterizeButton: UIButton!
    @IBOutlet private weak var vintageButton: UIButton!
    @IBOutlet private weak var invertButton: UIButton!

    @IBOutlet private weak var motionBlurStack: UIStackView!
    @IBOutlet private weak var edgesStack: UIStackView!
    @IBOutlet private weak var posterizeStack: UIStackView!

    @IBOutlet private weak var motionBlurRadiusSlider: UISlider!
    @IBOutlet private weak var motionBlurAngleSlider: UISlider!
    @IBOutlet private weak var edgesIntensitySlider: UISlider!
    @IBOutlet private weak var posterizeLevelsSlider: UISlider!

    private var filterTypesEnabled: [FilterType: Bool] = [
        .motionBlur: false,
        .edges: false,
        .posterize: false,
        .vintage: false,
        .invert: false
    ]
    private var anyFiltersEnabled: Bool { filterTypesEnabled.values.contains(true) }

    private lazy var typesForButton: [UIButton: FilterType] = [
        motionBlurButton: .motionBlur,
        edgesButton: .edges,
        posterizeButton: .posterize,
        vintageButton: .vintage,
        invertButton: .invert
    ]

    private var ciFilters: [FilterType: CIFilter?] = [
        .motionBlur: CIFilter(name: "CIMotionBlur"),
        .edges: CIFilter(name: "CIEdges"),
        .posterize: CIFilter(name: "CIColorPosterize"),
        .vintage: CIFilter(name: "CIPhotoEffectTransfer"),
        .invert: CIFilter(name: "CIColorInvert")
    ]
    // MARK: - View Lifecycle

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

    // MARK: - Actions
    
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

    @IBAction private func filterButtonTapped(_ sender: UIButton) {
        guard
            let filterType = typesForButton[sender]
            else { return }

        if let filterIsEnabled = filterTypesEnabled[filterType], filterIsEnabled {
            filterTypesEnabled[filterType] = false
        } else {
            filterTypesEnabled[filterType] = true
        }

        sender.setTitleColor(filterTypesEnabled[filterType]! ? .systemRed : .systemBlue,
                             for: .normal)

        switch filterType {
        case .motionBlur:
            motionBlurStack.isHidden.toggle()
        case .edges:
            edgesStack.isHidden.toggle()
        case .posterize:
            posterizeStack.isHidden.toggle()
        default: break
        }
    }
    // MARK: - Helper Methods
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
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
}

// MARK: - Image Picker Delegate

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
