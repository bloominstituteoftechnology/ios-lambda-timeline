//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController, FilterChooserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        hideFilterButton()
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
    
    @IBAction func sliderChanged(_ sender: Any) {
        updateImageView()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    // MARK: Filter Selection
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseFilter" {
            
            let navWrapper = segue.destination as! UINavigationController
            let filterChooser = navWrapper.viewControllers[0] as! FilterChooserViewController
            
            filterChooser.delegate = self
        }
    }
    
    func filterChooserViewController(_ viewController: FilterChooserViewController, didChooseFilter filter: CIFilter?) {
        
        viewController.dismiss(animated: true, completion: nil)
        
        if let newFilter = filter {
            self.filter = newFilter
        }
        
    }

    // MARK: - Private methods
    
    private func buildSliders() {
        for slider in sliders {
            controlStackView.removeArrangedSubview(slider.view)
            slider.view.removeFromSuperview()
        }
        
        sliders = filter.attributes.compactMap { (key, value) -> SliderInput? in
            return SliderInput(name: key, attributes: value)
            }.sorted {
                $0.displayName < $1.displayName
        }
        
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)
        
        for (offset, sliderInput) in sliders.enumerated() {
            controlStackView.insertArrangedSubview(sliderInput.view, at: offset)
            
            let slider = sliderInput.slider
            
            let equalWidth = slider.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor)
            equalWidth.isActive = true
            
            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        }
    }
    
    private func hideFilterButton() {
        addFilterButton.isEnabled = false
        addFilterButton.tintColor = UIColor.clear
    }
    
    private func unhideFilterButton() {
        addFilterButton.isEnabled = true
        addFilterButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    }
    
    private func applyFilter(to image: UIImage) -> UIImage {
        
        let inputImage: CIImage
        
        if let ciImage = image.ciImage {
            inputImage = ciImage
        } else if let cgImage = image.cgImage {
            inputImage = CIImage(cgImage: cgImage)
        } else {
            // 🤷‍♂️
            return image
        }
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        for sliderAttribute in sliders {
            let value = sliderAttribute.slider.value
            filter.setValue(value, forKey: sliderAttribute.attributeName)
        }
        
        
        guard let outputImage = filter.outputImage else {
            return image
        }
        
        // convert to CGImage because Photos only likes images with CGImage data
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func updateImageView() {
        guard let image = originalImage else { return }
        imageView?.image = applyFilter(to: image)
    }
    
    // MARK: - Properties
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    private var sliders = Array<SliderInput>()
    @IBOutlet weak var controlStackView: UIStackView!
    private var filter = CIFilter(name: "CIFalseColor")! {
        didSet {
            buildSliders()
            updateImageView()
        }
    }
    private var originalImage: UIImage? {
        didSet {
            updateImageView()
        }
    }
    private let context = CIContext(options: nil)
    
    @IBOutlet weak var addFilterButton: UIBarButtonItem!
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
        unhideFilterButton()
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
