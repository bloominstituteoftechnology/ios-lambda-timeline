//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: ShiftableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var addFilterLabel: UILabel!
    @IBOutlet weak var clearFiltersButton: UIButton!
    @IBOutlet weak var toneButton: UIButton!
    @IBOutlet weak var vintageButton: UIButton!
    @IBOutlet weak var noirButton: UIButton!
    @IBOutlet weak var tweakLabel: UILabel!
    @IBOutlet weak var exposureLabel: UILabel!
    @IBOutlet weak var exposureSlider: UISlider!
    @IBOutlet weak var vibranceLabel: UILabel!
    @IBOutlet weak var vibranceSlider: UISlider!
    @IBOutlet weak var posterizeLabel: UILabel!
    @IBOutlet weak var posterizeSlider: UISlider!
    
    @IBOutlet weak var addLocationLabel: UILabel!
    @IBOutlet weak var addLocationSwitch: UISwitch!
    
    private let context = CIContext()
    private let toneFilter = CIFilter.sRGBToneCurveToLinear()
    private let vintageFilter = CIFilter.photoEffectInstant()
    private let noirFilter = CIFilter.photoEffectNoir()
    private let exposureFilter = CIFilter.exposureAdjust()
    private let vibranceFilter = CIFilter.vibrance()
    private let posterizeFilter = CIFilter.colorPosterize()
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var selectedFilter: CIFilter?
    var getLocation = false
    var currentLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {
                scaledImage = nil
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = imageView.contentScaleFactor
            
            scaledSize.width *= scale
            scaledSize.height *= scale
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        addLocationSwitch.setOn(false, animated: true)
        
        addFilterLabel.isHidden = true
        clearFiltersButton.isHidden = true
        toneButton.isHidden = true
        vintageButton.isHidden = true
        noirButton.isHidden = true
        tweakLabel.isHidden = true
        exposureLabel.isHidden = true
        exposureSlider.isHidden = true
        vibranceLabel.isHidden = true
        vibranceSlider.isHidden = true
        posterizeLabel.isHidden = true
        posterizeSlider.isHidden = true
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
    
    private func image(byFiltering inputImage: CIImage, withFilter inputFilter: CIFilter?) -> UIImage? {
        var output = inputImage
        
        if inputFilter == toneFilter {
            toneFilter.inputImage = inputImage
            output = toneFilter.outputImage!
        } else if inputFilter == vintageFilter {
            vintageFilter.inputImage = inputImage
            output = vintageFilter.outputImage!
        } else if inputFilter == noirFilter {
            noirFilter.inputImage = inputImage
            output = noirFilter.outputImage!
        }
        
        exposureFilter.inputImage = output
        exposureFilter.ev = exposureSlider.value
        
        vibranceFilter.inputImage = exposureFilter.outputImage
        vibranceFilter.amount = vibranceSlider.value
        
        posterizeFilter.inputImage = vibranceFilter.outputImage
        posterizeFilter.levels = posterizeSlider.value
        
        guard let outputImage = posterizeFilter.outputImage else { return nil }
        
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        
        return UIImage(cgImage: renderedCGImage)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage, withFilter: selectedFilter)
        } else {
            imageView.image = nil
        }
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let image = imageView.image,
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }

        postController.createImagePost(with: title, image: image, ratio: image.ratio, geotag: currentLocation)
        
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
    
    @IBAction func toggleLocation(_ sender: Any) {
        if addLocationSwitch.isOn {
            locationManager.requestWhenInUseAuthorization()
            getLocation = true
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        } else {
            getLocation = false
            currentLocation = nil
        }
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    @IBAction func clearFilters(_ sender: Any) {
        selectedFilter = nil
        exposureSlider.value = 0.5
        vibranceSlider.value = 0
        posterizeSlider.value = 50
        updateImage()
    }
    
    @IBAction func addToneFilter(_ sender: Any) {
        selectedFilter = toneFilter
        updateImage()
    }
    
    @IBAction func addVintageFilter(_ sender: Any) {
        selectedFilter = vintageFilter
        updateImage()
    }
    
    @IBAction func addNoirFilter(_ sender: Any) {
        selectedFilter = noirFilter
        updateImage()
    }
    
    @IBAction func expoureChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func vibranceChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func posterizeChanged(_ sender: Any) {
        updateImage()
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
        
        addFilterLabel.isHidden = false
        clearFiltersButton.isHidden = false
        toneButton.isHidden = false
        vintageButton.isHidden = false
        noirButton.isHidden = false
        tweakLabel.isHidden = false
        exposureLabel.isHidden = false
        exposureSlider.isHidden = false
        vibranceLabel.isHidden = false
        vibranceSlider.isHidden = false
        posterizeLabel.isHidden = false
        posterizeSlider.isHidden = false
        
        exposureSlider.value = 0.5
        vibranceSlider.value = 0
        posterizeSlider.value = 50
        
        originalImage = imageView.image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension ImagePostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        if getLocation {
            currentLocation = locValue
        }
    }
}
