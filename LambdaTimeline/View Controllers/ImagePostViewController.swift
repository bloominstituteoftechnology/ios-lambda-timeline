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

class ImagePostViewController: ShiftableViewController {
    // MARK: - Outlets -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!

    //Stack Views
    @IBOutlet weak var mainFilterStack: UIStackView!
    @IBOutlet weak var colorStack1: UIStackView!
    @IBOutlet weak var colorStack2: UIStackView!
    @IBOutlet weak var sliderStack1: UIStackView!
    @IBOutlet weak var sliderStack2: UIStackView!
    @IBOutlet weak var sliderStack3: UIStackView!


    //Slider Labels
    @IBOutlet weak var slider1Label: UILabel!
    @IBOutlet weak var slider2Label: UILabel!
    @IBOutlet weak var slider3Label: UILabel!
    //Sliders
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!

    // MARK: - Properties -
    var postController: PostController!
    var post: Post?
    var imageData: Data?

    var color1: CIColor = CIColor(color: UIColor.black)
    var color2: CIColor = CIColor(color: UIColor.white)
    private let context = CIContext(options: nil)
    private var filter: CIFilter = CIFilter(name: Filter.gaussian.rawValue)! {
        didSet {
            updatePhoto()
        }
    }

    private var pickedImage: UIImage? {
        didSet {
            guard let originalImage = pickedImage else {
                scaledImage = nil
                alertUnknownEdgeCase()
                return
            }

            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }

    private var scaledImage: UIImage? {
        didSet {
            updatePhoto()
        }
    }

    private var inputImage: CIImage? {
        guard let originalImage = scaledImage,
            let cgImage = originalImage.cgImage else {
                alertUnknownEdgeCase()
                return nil
        }
        let ciImage = CIImage(cgImage: cgImage)
        return ciImage
    }

    private func updatePhoto() {
        //it's easy to miss something when using a bool to switch states
        //and there's no point in setting up a filter with no UI
        guard !mainFilterStack.isHidden else {
            alertUnknownEdgeCase()
            return
        }
        switch filter.name {
        case Filter.gaussian.rawValue:
            setupGaussianFilter()
        case Filter.checkerboard.rawValue:
            setupCheckerboardFilter()
        case Filter.contrast.rawValue:
            setupColorControlsFilter()
        case Filter.sepia.rawValue:
            setupSepiaFilter()
        case Filter.bloom.rawValue:
            setupBloomFilter()
        default:
            break
        }
    }

    @IBAction func filterControl(_ sender: UISegmentedControl) {
        filter = CIFilter(name: Filter.allCases[sender.selectedSegmentIndex].rawValue)!
        switch filter.name {
        case Filter.gaussian.rawValue:
            setupGaussianUI()
        case Filter.checkerboard.rawValue:
            setupCheckerboardUI()
        case Filter.contrast.rawValue:
            setupColorControlsUI()
        case Filter.sepia.rawValue:
            setupSepiaUI()
        case Filter.bloom.rawValue:
            setupBloomUI()
        default:
            break
        }
    }

    // MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        mainFilterStack.isHidden = true
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }

        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])

        //Ask user to add filter to existing photo
        Alert.withYesNoPrompt(
            title: "Filter This Photo?",
            message: "Would you like to add a filter?",
            vc: self) { (filterChosen) in
                if filterChosen {
                    self.mainFilterStack.isHidden = false
                    self.pickedImage = image
                    guard let scaledImage = self.scaledImage else {
                        self.alertUnknownEdgeCase()
                        return
                    }
                    self.setImageViewHeight(with: scaledImage.ratio)
                    self.setupGaussianUI()
                    self.setupGaussianFilter()
                } else {
                    self.imageView.image = image
                    self.setImageViewHeight(with: image.ratio)
                }
        }
    }

    // MARK: - Image Picker -
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
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
    
    private func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }

    private func alertUnknownEdgeCase() {
        presentInformationalAlertController(
            title: "Oops!",
            message: "An unknown error occurred. Please go back and try again."
        )
    }
    
    // MARK: - Actions -
    @IBAction func color1WasTapped(_ sender: UIButton) {
        color1 = CIColor(color: sender.backgroundColor ?? .black)
        updatePhoto()
    }

    @IBAction func color2WasTapped(_ sender: UIButton) {
        color2 = CIColor(color: sender.backgroundColor ?? .white)
        updatePhoto()
    }

    @IBAction func filterSlider1DidChange(_ sender: UISlider) {
        updatePhoto()
    }

    @IBAction func filterSlider2DidChange(_ sender: UISlider) {
        updatePhoto()
    }

    @IBAction func filterSlider3DidChange(_ sender: UISlider) {
        updatePhoto()
    }

}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            alertUnknownEdgeCase()
            return
        }
        Alert.withYesNoPrompt(
            title: "Filter This Photo?",
            message: "Would you like to add a filter?",
            vc: self) { (filterChosen) in
                if filterChosen {
                    self.mainFilterStack.isHidden = false
                    self.pickedImage = image
                    guard let scaledImage = self.scaledImage else {
                        self.alertUnknownEdgeCase()
                        return
                    }
                    self.setImageViewHeight(with: scaledImage.ratio)
                    self.setupGaussianUI()
                    self.setupGaussianFilter()
                } else {
                    self.imageView.image = image
                    self.setImageViewHeight(with: image.ratio)
                }
        }


    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Filter Implementations -
extension ImagePostViewController {
    //Guassian Blur
    func setupGaussianUI() {
        imageView.image = scaledImage
        colorStack1.isHidden = true
        colorStack2.isHidden = true
        slider1Label.text = "Radius"
        slider1.isHidden = false
        slider1.value = 1
        slider1.minimumValue = 0
        slider1.maximumValue = 10
        sliderStack2.isHidden = true
        sliderStack3.isHidden = true
    }

    func setupGaussianFilter() {
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputRadiusKey)

        filterImage()
    }

    //Checkerboard Generator
    func setupCheckerboardUI() {
        colorStack1.isHidden = false
        colorStack2.isHidden = false

        slider1Label.text = "Square Width"
        sliderStack1.isHidden = false
        slider1.value = 80
        slider1.minimumValue = 0
        slider1.maximumValue = 160

        slider2Label.text = "Sharpness"
        sliderStack2.isHidden = false
        slider2.value = 1
        slider2.minimumValue = 0
        slider2.maximumValue = 1

        sliderStack3.isHidden = true
        setupCheckerboardFilter()
    }

    func setupCheckerboardFilter() {
        let color1Key = "inputColor0"
        let color2Key = "inputColor1"
        filter.setValue(color1, forKey: color1Key)
        filter.setValue(color2, forKey: color2Key)
        filter.setValue(slider1.value, forKey: kCIInputWidthKey)
        filter.setValue(slider2.value, forKey: kCIInputSharpnessKey)
        filter.setValue((CIVector(cgPoint: (imageView.center))), forKey: kCIInputCenterKey)

        filterImage()
    }

    //Color Controls
    func setupColorControlsUI() {
        imageView.image = scaledImage
        colorStack1.isHidden = true
        colorStack2.isHidden = true

        slider1Label.text = "Brightness"
        sliderStack1.isHidden = false
        slider1.value = 0
        slider1.minimumValue = -1
        slider1.maximumValue = 1

        slider2Label.text = "Contrast"
        sliderStack2.isHidden = false
        slider2.value = 1
        slider2.minimumValue = 0.25
        slider2.maximumValue = 4

        slider3Label.text = "Saturation"
        sliderStack3.isHidden = false
        slider3.value = 1
        slider3.minimumValue = 0
        slider3.maximumValue = 2
    }

    func setupColorControlsFilter() {
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputBrightnessKey)
        filter.setValue(slider2.value, forKey: kCIInputContrastKey)
        filter.setValue(slider3.value, forKey: kCIInputSaturationKey)

        filterImage()
    }

    //Sepia
    func setupSepiaUI() {
        imageView.image = scaledImage
        colorStack1.isHidden = true
        colorStack2.isHidden = true

        sliderStack1.isHidden = false
        slider1Label.text = "Intensity"
        slider1.value = 5
        slider1.minimumValue = 0
        slider1.maximumValue = 2

        sliderStack2.isHidden = true
        sliderStack3.isHidden = true
    }

    func setupSepiaFilter() {
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputIntensityKey)
        filterImage()
    }

    //Bloom
    func setupBloomUI() {
        imageView.image = scaledImage
        colorStack1.isHidden = true
        colorStack2.isHidden = true

        sliderStack1.isHidden = false
        slider1Label.text = "Intensity"
        slider1.value = 0.5
        slider1.minimumValue = 0
        slider1.maximumValue = 1

        sliderStack2.isHidden = false
        slider2Label.text = "Radius"
        slider2.value = 5
        slider2.minimumValue = 0
        slider2.maximumValue = 10
    }

    func setupBloomFilter() {
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputIntensityKey)
        filter.setValue(slider2.value, forKey: kCIInputRadiusKey)
        filterImage()
    }

    private func filterImage() {
        if let outputImage = filter.outputImage,
            let image = scaledImage,
            let filteredImage = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: image.size)) {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(cgImage: filteredImage)
            }
        }
    }
}

