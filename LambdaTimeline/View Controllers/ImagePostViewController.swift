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
    
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
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
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let image = imageView.image,
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }

        postController.createImagePost(with: title, image: image, ratio: image.ratio)
        
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
    
    @IBAction func clearFilters(_ sender: Any) {
        
    }
    
    @IBAction func addToneFilter(_ sender: Any) {
        
    }
    
    @IBAction func addVintageFilter(_ sender: Any) {
        
    }
    
    @IBAction func addNoirFilter(_ sender: Any) {
        
    }
    
    @IBAction func expoureChanged(_ sender: Any) {
        
    }
    
    @IBAction func vibranceChanged(_ sender: Any) {
        
    }
    
    @IBAction func posterizeChanged(_ sender: Any) {
        
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
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
