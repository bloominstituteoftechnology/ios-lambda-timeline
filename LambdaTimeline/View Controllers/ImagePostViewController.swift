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

enum FilterType : String  {
    case CIPerspectiveTile
    case CIComicEffect
    case CISixfoldReflectedTile
    case CISpotColor
    case CIColorMatrix
}

class ImagePostViewController: ShiftableViewController {
    
    //MARK:- Properties
    private var originalImage: UIImage? {
          didSet {
             // resize a scaledImage anytime this property is set, so that the UI can update
              // faster with a "live preview"
              guard let originalImage = originalImage else { return }
              var scaledSize = imageView.bounds.size
              let scale = UIScreen.main.scale // 1x (no iPhones) 2x 3x
              //how many pixels can we fit on the screen?
              
         
              scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
              scaledImage = originalImage.imageByScaling(toSize: scaledSize)
          }
      }
    
    private var scaledImage: UIImage? {
           didSet {
            updateImage()
           }
       }
       
    var postController: PostController!
     var post: Post?
     var imageData: Data?
     private var context = CIContext(options: nil)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField! {
        didSet {
            titleTextField.becomeFirstResponder()
        }
    }
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var brightnessLabel: UILabel! {
        didSet {    brightnessLabel.isHidden = true }
         
    }
    @IBOutlet weak var brightnessSlider: UISlider! {
        didSet {   brightnessSlider.isHidden = true   }
    }
    
    
    @IBOutlet weak var saturationLabel: UILabel! {
        didSet {     saturationLabel.isHidden = true   }
     
    }
    @IBOutlet weak var saturationSlider: UISlider! {
        didSet {  saturationSlider.isHidden = true    }
   
    }

    @IBOutlet weak var constrastLabel: UILabel! {
        didSet {    constrastLabel.isHidden = true }
     
    }
    @IBOutlet weak var constrastSlider: UISlider! {
        didSet {  constrastSlider.isHidden = true   }
    }
    
    
    @IBOutlet weak var pickFilterButton: UIButton! {
        didSet {
            pickFilterButton.isEnabled = false
        }
    }
    
    @IBAction func pickFilerTapped(_ sender: UIButton) {
        showFilerOptions()
      }
    
    private func unhideUI()  {
        self.brightnessLabel.isHidden = false
        self.brightnessSlider.isHidden = false
        
        self.saturationLabel.isHidden = false
        self.saturationSlider.isHidden = false
        
        self.constrastLabel.isHidden = false
        self.constrastSlider.isHidden = false
    }
    
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateImage()
    }
    
    
    @IBAction func saturationChanged(_ sender: UISlider) {
        updateImage()
    }
    
    
    @IBAction func contrastChanged(_ sender: UISlider) {
      updateImage()
    }
    
    private func filterColorControl(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
       let filter = CIFilter.colorControls()
        
        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = constrastSlider.value
        filter.saturation = saturationSlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size) ) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func filterColorMatrix(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIColorMatrix")
        filter?.setDefaults()
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        filter?.setValue(CIVector(x: 31, y: 0.1, z: 0.1, w: 0), forKey: "inputRVector")
        filter?.setValue(CIVector(x: 20, y: 1, z: 320, w: 0), forKey: "inputGVector")
        filter?.setValue(CIVector(x: 420, y: 0, z: 321, w: 0), forKey: "inputBVector")
        
        
        guard let outputCIImage = filter?.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size) ) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func filterPerspective(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter =   CIFilter.perspectiveTile()
        
        filter.inputImage = ciImage
        filter.topLeft = CGPoint(x: 200, y: 320)
        filter.topRight = CGPoint(x: 2, y: 2)
        filter.bottomLeft = CGPoint(x: 0, y: 269)
        filter.bottomRight = CGPoint(x: 569, y: 4)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size) ) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func filterComicEffect(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.comicEffect()
        
        filter.inputImage = ciImage
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size) ) else { return nil }
              
              return UIImage(cgImage: outputCGImage)
    }
    private func filterSpotColor(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.spotColor()
        
         filter.inputImage = ciImage
        filter.centerColor1 = .red
        filter.contrast1 = .leastNonzeroMagnitude
        filter.centerColor2 = .yellow
        filter.contrast2 = .leastNonzeroMagnitude
        filter.centerColor3 = .cyan
        filter.contrast3 = .infinity
        filter.closeness1 = .infinity
        filter.closeness2 = .leastNonzeroMagnitude
        filter.closeness3 = .leastNonzeroMagnitude
        filter.setValue(ciImage, forKey: kCICategoryStylize)
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size) ) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }

    func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = filterColorControl(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    
  
    
    private func showFilerOptions() {
        let ac = UIAlertController(title: "Pick a filter to image", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Color Change", style: .default, handler: { (action) in
            self.pickFilterButton.setTitle("Color Change", for: .normal)
            self.unhideUI()
            // zero
        }))
        ac.addAction(UIAlertAction(title: FilterType.CIColorMatrix.rawValue, style: .default, handler: { (action) in
            self.pickFilterButton.setTitle(FilterType.CIColorMatrix.rawValue, for: .normal)
           // one
            self.imageView.image =  self.filterColorMatrix(self.scaledImage!)
        }))
        ac.addAction(UIAlertAction(title: FilterType.CISpotColor.rawValue, style: .default, handler: { (action) in
            // two
              self.pickFilterButton.setTitle(FilterType.CISpotColor.rawValue, for: .normal)
            
            if let scaledImage = self.scaledImage {
                self.imageView.image = self.filterSpotColor(scaledImage)
            } else {
                self.imageView.image = nil
            }
            
        }))
        ac.addAction(UIAlertAction(title: FilterType.CIComicEffect.rawValue, style: .default, handler: { (action) in
            //three
             self.pickFilterButton.setTitle(FilterType.CIComicEffect.rawValue, for: .normal)
//            guard let scaled = self.scaledImage else { return }
//            self.imageView.image = self.filterComicEffect(scaled)
        }))
        ac.addAction(UIAlertAction(title: FilterType.CIPerspectiveTile.rawValue, style: .default, handler: { (action) in
            //four
            self.pickFilterButton.setTitle(FilterType.CIPerspectiveTile.rawValue, for: .normal)
            
            if let scaledImage = self.scaledImage {
                self.imageView.image = self.filterPerspective(scaledImage)
            } else {
                self.imageView.image = nil
            }
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(ac, animated: true)
      
        
    }
    
    //MARK:- View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.hideKeyboardWhenTappedAround() 
        originalImage = imageView.image
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    
    
    @IBAction func titleTextFieldDidChanged(_ sender: UITextField) {
        navigationItem.title = sender.text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationItem.title = textField.text
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
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                
                imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
              
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
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
 
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        pickFilterButton.isEnabled = true
        
        picker.dismiss(animated: true, completion: nil)
    
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
