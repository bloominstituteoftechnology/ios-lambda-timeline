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
import CoreImage.CIFilterBuiltins
import MapKit

class ImagePostViewController: ShiftableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var sharpenSlider: UISlider!
    @IBOutlet weak var vignetteSlider: UISlider!
    @IBOutlet weak var sepiaSlider: UISlider!
    @IBOutlet weak var monoChromaticSlider: UISlider!
    @IBOutlet weak var locationSwitch: UISwitch!
    
    // MARK: - Properties
    let postController = PostController.shared
    var post: Post?
    var imageData: Data?
    
    var originalImage: UIImage?{
        didSet{
            guard let originalImage = originalImage else {
                scaledImage = nil
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = imageView.contentScaleFactor
            
            scaledSize = CGSize(width: scaledSize.width*scale, height: scaledSize.height*scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    var scaledImage: CIImage?{
        didSet{
            updateImage()
        }
    }
    
    let context = CIContext()
    
    let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageViewHeight(with: 1.0)
        originalImage = imageView.image
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Methods
    private func image(byFiltering image: CIImage) -> UIImage? {
        let inputImage = image
        
        // Blur
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = inputImage
        blurFilter.radius = blurSlider.value
        
        // Sharpen
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = blurFilter.outputImage?.clampedToExtent()
        sharpenFilter.sharpness =  sharpenSlider.value
        
        // Vignette
        let vignetteFilter = CIFilter.vignette()
        vignetteFilter.inputImage = sharpenFilter.outputImage?.clampedToExtent()
        vignetteFilter.intensity = vignetteSlider.value * 2
        vignetteFilter.radius = vignetteSlider.value * 100
        
        // Sepia
        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.inputImage = vignetteFilter.outputImage?.clampedToExtent()
        sepiaFilter.intensity = sepiaSlider.value
        
        // MonoChromatic
        let monochromaticFilter = CIFilter.colorMonochrome()
        monochromaticFilter.inputImage = sepiaFilter.outputImage?.clampedToExtent()
        monochromaticFilter.intensity = monoChromaticSlider.value
        
        guard let outputImage = monochromaticFilter.outputImage else { return nil }
        
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil}
        
        return UIImage(cgImage: renderedCGImage)
        
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func locationSwitchIsOn(_ sender: UISwitch) {
        if sender.isOn {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let image = imageView.image,
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        let newLocation = locationManager.location?.coordinate
        
        postController.createImagePost(with: title, image: image, ratio: image.ratio, audioURL: nil, location: newLocation!)
        
        navigationController?.popViewController(animated: true)
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
        default:
            break
        }
        presentImagePickerController()
    }
    
    @IBAction func addFilter(_ sender: Any) {
        
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    // MARK: - IBActions
    @IBAction func blurSliderChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func sharpenSliderChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func vignetteSliderChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func sepiaSliderChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func monoChromaticSliderChanged(_ sender: Any) {
        updateImage()
    }
    
}

// MARK: - Extenstions
extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        
        //        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagePostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print(error)
    }
}
