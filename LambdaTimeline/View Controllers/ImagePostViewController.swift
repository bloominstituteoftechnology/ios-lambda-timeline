
import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        blackWhiteSwitch.isOn = false
        vintageSwitch.isOn = false
        
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
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    // MARK: - Private Properties
    
    private func configureSlider(_ slider: UISlider, from attributes: Any?) {
        
        // If attributes are not actually a dictionary, use an empty dictionary
        let attrs = attributes as? [String: Any] ?? [:]
        
        // Pull out 3 values that I care about
        if let min = attrs[kCIAttributeSliderMin] as? Float,
            let max = attrs[kCIAttributeSliderMax] as? Float,
            let value = attrs[kCIAttributeDefault] as? Float {
            
            // Set the 3 values on my sliders
            slider.minimumValue = min
            slider.maximumValue = max
            slider.value = value
            
        } else {
            // if they are missing, choose a reasonable default
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.value = 0.5
        }
    }
    
    private func updateImageView() {
        
        // Make sure I have an image
        guard var image = originalImage else { return }
        
        // Put image into my image view and apply any filter I might have to the image
        image = applyTonalFilter(to: image)
        image = applyTransferFilter(to: image)
        image = applyMonochromeFilter(to: image)
        image = applyPixellateFilter(to: image)
        image = applyZoomBlurFilter(to: image)
        
        //imageView?.image = applyFilterChain(to: image)
        imageView.image = image
        
    }
    
    private func applyFilterChain(to image: UIImage) -> UIImage {
        
        let inputImage: CIImage
        
        // If we happen to have a CIImage, use that
        if let ciImage = image.ciImage {
            inputImage = ciImage
        } else if let cgImage = image.cgImage {
            // if we get a cgImage, convert it to a ciImage
            inputImage = CIImage(cgImage: cgImage)
        } else {
            // 🤷🏼‍♀️ if we don't have either, we have no idea what to do in this case
            return image
        }
        
        // CIPhotoEffectTonal filter only takes an input image
        
        tonalFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        
        // Pass result of tonal filter to CIPhotoEffectTransfer
        if let tonalOutput = tonalFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            transferFilter?.setValue(tonalOutput, forKey: kCIInputImageKey)
            
            if let transferOutput = transferFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                monochromeFilter?.setValue(transferOutput, forKey: kCIInputImageKey)
                monochromeFilter?.setValue(CIColor(red: 0.25, green: 0.92, blue: 0.83), forKey: "inputColor")
                monochromeFilter?.setValue(monochromeSlider.value, forKey: kCIInputIntensityKey)
                
                if let monochromeOutput = monochromeFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                    pixellateFilter?.setValue(monochromeOutput, forKey: kCIInputImageKey)
                    pixellateFilter?.setValue(pixellateSlider.value, forKey: kCIInputScaleKey)
                    
                    if let pixellateOutput = pixellateFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                        zoomBlurFilter?.setValue(pixellateOutput, forKey: kCIInputImageKey)
                        zoomBlurFilter?.setValue(zoomBlurSlider.value, forKey: kCIInputAmountKey)
                        
                        if let zoomBlurOutput = zoomBlurFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                            
                            // Convert back
                            guard let cgImage = context.createCGImage(zoomBlurOutput, from: zoomBlurOutput.extent) else {
                                return image
                            }
                            
                            self.imageView.image = UIImage(cgImage: cgImage)
                            
                            return UIImage(cgImage: cgImage)
                            
                        }
                    }
                }
            }
        }
        
        
        return image
    }
    
    private func applyTonalFilter(to image: UIImage) -> UIImage {
        
        let inputImage: CIImage
        
        // If we happen to have a CIImage, use that
        if let ciImage = image.ciImage {
            inputImage = ciImage
            
        } else if let cgImage = image.cgImage {
            // if we get a cgImage, convert it to a ciImage
            inputImage = CIImage(cgImage: cgImage)
            
        } else {
            // 🤷🏼‍♀️ if we don't have either, we have no idea what to do in this case
            return image
        }

        if blackWhiteSwitch.isOn {
            tonalFilter?.setValue(inputImage, forKey: "inputImage")
            
            // Retrieve image from filter
            guard let outputImage = tonalFilter?.outputImage else {
                return image
            }
            
            // Convert back
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return image
            }
            
            return UIImage(cgImage: cgImage)
        }
        
        return image
    }
    
    private func applyTransferFilter(to image: UIImage) -> UIImage {
        
        let inputImage: CIImage
        
        // If we happen to have a CIImage, use that
        if let ciImage = image.ciImage {
            inputImage = ciImage
            
        } else if let cgImage = image.cgImage {
            // if we get a cgImage, convert it to a ciImage
            inputImage = CIImage(cgImage: cgImage)
            
        } else {
            // 🤷🏼‍♀️ if we don't have either, we have no idea what to do in this case
            return image
        }
        
        if vintageSwitch.isOn == true {
            transferFilter?.setValue(inputImage, forKey: "inputImage")
            
            // Retrieve image from filter
            guard let outputImage = transferFilter?.outputImage else {
                return image
            }
            
            // Convert back
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return image
            }
            
            return UIImage(cgImage: cgImage)
        }
        
        return image
    }
    
    private func applyMonochromeFilter(to image: UIImage) -> UIImage {
        
        // CIColorMonochrome [inputImage, inputColor, inputIntensity]
        //  - inputIntensity: slider [0.0...1.0]
        //  - inputColor: cgColor
        
        let inputImage: CIImage
        
        // If we happen to have a CIImage, use that
        if let ciImage = image.ciImage {
            inputImage = ciImage
            
        } else if let cgImage = image.cgImage {
            // if we get a cgImage, convert it to a ciImage
            inputImage = CIImage(cgImage: cgImage)
            
        } else {
            // 🤷🏼‍♀️ if we don't have either, we have no idea what to do in this case
            return image
        }
        
        monochromeFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        monochromeFilter?.setValue(CIColor(red: 0.25, green: 0.92, blue: 0.83), forKey: "inputColor")
        monochromeFilter?.setValue(monochromeSlider.value, forKey: kCIInputIntensityKey)
        
        // Retrieve image from filter
        guard let outputImage = monochromeFilter?.outputImage else {
            return image
        }
        
        // Convert back
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        self.imageView.image = UIImage(cgImage: cgImage)
        
        return UIImage(cgImage: cgImage)
    
    }
    
    private func applyPixellateFilter(to image: UIImage) -> UIImage {
        
        // CIPixellate [inputImage, inputCenter, inputScale]
        //  - inputScale: slider [1...100]
        //  - inputCenter: CIVector - default = ["150 150"]
        
        let inputImage: CIImage
        
        // If we happen to have a CIImage, use that
        if let ciImage = image.ciImage {
            inputImage = ciImage
            
        } else if let cgImage = image.cgImage {
            // if we get a cgImage, convert it to a ciImage
            inputImage = CIImage(cgImage: cgImage)
            
        } else {
            // 🤷🏼‍♀️ if we don't have either, we have no idea what to do in this case
            return image
        }
        
        pixellateFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        pixellateFilter?.setValue(pixellateSlider.value, forKey: kCIInputScaleKey)
        
        // Retrieve image from filter
        guard let outputImage = pixellateFilter?.outputImage else {
            return image
        }
        
        // Convert back
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        self.imageView.image = UIImage(cgImage: cgImage)
        
        return UIImage(cgImage: cgImage)
    }
    
    private func applyZoomBlurFilter(to image: UIImage) -> UIImage {
        
        // CIZoomBlur [inputImage, inputCenter, inputAmount]
        //  - inputAmount: slider [-200...200]
        //  - inputCenter: CIVector - default = ["150 150"]
        
        let inputImage: CIImage
        
        // If we happen to have a CIImage, use that
        if let ciImage = image.ciImage {
            inputImage = ciImage
            
        } else if let cgImage = image.cgImage {
            // if we get a cgImage, convert it to a ciImage
            inputImage = CIImage(cgImage: cgImage)
            
        } else {
            // 🤷🏼‍♀️ if we don't have either, we have no idea what to do in this case
            return image
        }
        
        zoomBlurFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        zoomBlurFilter?.setValue(zoomBlurSlider.value, forKey: kCIInputAmountKey)
        
        // Retrieve image from filter
        guard let outputImage = zoomBlurFilter?.outputImage else {
            return image
        }
        
        // Convert back
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        self.imageView.image = UIImage(cgImage: cgImage)
        
        return UIImage(cgImage: cgImage)

    }
    
    
    @IBAction func switchChanged(_ sender: Any) {
        updateImageView()
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        updateImageView()
    }
    
    // MARK: - Properties
    
    private let tonalFilter = CIFilter(name: "CIPhotoEffectTonal")
    private let transferFilter = CIFilter(name: "CIPhotoEffectTransfer")
    private let monochromeFilter = CIFilter(name: "CIColorMonochrome")
    private let pixellateFilter = CIFilter(name: "CIPixellate")
    private let zoomBlurFilter = CIFilter(name: "CIZoomBlur")
    
    private let context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        // Need to know when the user has picked the image
        didSet {
            updateImageView()
        }
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var blackWhiteSwitch: UISwitch!
    @IBOutlet weak var vintageSwitch: UISwitch!
    @IBOutlet weak var monochromeSlider: UISlider!
    @IBOutlet weak var pixellateSlider: UISlider!
    @IBOutlet weak var zoomBlurSlider: UISlider!
    
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
        
        //imageView.image = image
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
