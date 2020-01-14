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

    var originalImage: UIImage? {
        didSet { scaledImage = scaleImage(originalImage) }
    }
    var scaledImage: UIImage? {
        didSet { filterPreviewImage() }
    }
    var context = CIContext(options: nil)

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
        
        setImageViewHeight(forAspectRatio: 1.0)

        updateViews()
    }
    
    func updateViews() {
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(forAspectRatio: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }

    // MARK: - Actions
    
    @IBAction func createPost(_ sender: Any) {
        view.endEditing(true)

        guard let filteredImage = filterImage(originalImage),
            let imageData = filteredImage.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != ""
            else {
                presentInformationalAlertController(
                    title: "Uh-oh",
                    message: "Make sure that you add a photo and a caption before posting.")
                return
        }

        postController.createPost(
            with: title,
            ofType: .image,
            mediaData: imageData,
            ratio: imageView.image?.ratio
        ) { success in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(
                        title: "Error",
                        message: "Unable to create post. Try again.")
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
                DispatchQueue.main.async {
                    self.presentImagePickerController()
                }
            }
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
        @unknown default: break
        }
        presentImagePickerController()
    }

    @IBAction private func filterButtonTapped(_ sender: UIButton) {
        guard
            let filterType = typesForButton[sender]
            else { return }

        var filterIsEnabled = filterTypesEnabled[filterType] ?? false
        filterIsEnabled.toggle()
        filterTypesEnabled[filterType] = filterIsEnabled

        sender.setTitleColor(filterIsEnabled ? .systemRed : .systemBlue,
                             for: .normal)

        switch filterType {
        case .motionBlur:
            motionBlurStack.isHidden = !filterIsEnabled
        case .edges:
            edgesStack.isHidden = !filterIsEnabled
        case .posterize:
            posterizeStack.isHidden = !filterIsEnabled
        default: break
        }

        filterPreviewImage()
    }

    @IBAction private func filterSliderChanged(_ sender: UISlider) {
        filterPreviewImage()
    }

    // MARK: - Helper Methods

    private func filterImage(_ image: UIImage?) -> UIImage? {
        guard
            anyFiltersEnabled,
            let startingImage = image, // this isn't working...
            let cgImage = startingImage.cgImage
            else { return image }
        var ciImage = CIImage(cgImage: cgImage)

        for (filterType, ciFilter) in ciFilters {
            guard
                let filter = ciFilter,
                let filterIsEnabled = filterTypesEnabled[filterType],
                filterIsEnabled
                else { continue }

            switch filterType {
            case .motionBlur:
                filter.setValuesForKeys([
                    kCIInputImageKey: ciImage,
                    kCIInputRadiusKey: motionBlurRadiusSlider.value,
                    kCIInputAngleKey: motionBlurAngleSlider.value
                ])
            case .edges:
                filter.setValuesForKeys([
                    kCIInputImageKey: ciImage,
                    kCIInputIntensityKey: edgesIntensitySlider.value
                ])
            case .posterize:
                filter.setValuesForKeys([
                    kCIInputImageKey: ciImage,
                    "inputLevels": posterizeLevelsSlider.value
                ])
            default:
                filter.setValue(ciImage, forKey: kCIInputImageKey)
            }

            guard let filterOutput = filter.outputImage else { continue }
            ciImage = filterOutput
        }

        guard let outputCGImage = context.createCGImage(
            ciImage,
            from: CGRect(origin: CGPoint.zero,
                         size: startingImage.size))
            else { return startingImage }

        return UIImage(cgImage: outputCGImage)
    }

    private func scaleImage(_ image: UIImage?) -> UIImage? {
        // Height and width
        var scaledSize = imageView.bounds.size
        // 1x, 2x, or 3x
        let scale = UIScreen.main.scale
        scaledSize = CGSize(width: scaledSize.width * scale,
                            height: scaledSize.height * scale)
        return image?.imageByScaling(toSize: scaledSize)
    }

    private func filterPreviewImage() {
        imageView.image = filterImage(scaledImage)
    }
    
    private func setImageViewHeight(forAspectRatio aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }

    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(
                title: "Error",
                message: "The photo library is unavailable")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary

        self.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - Image Picker Delegate

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage]
            as? UIImage
            else { return }
        originalImage = image
        
        setImageViewHeight(forAspectRatio: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
