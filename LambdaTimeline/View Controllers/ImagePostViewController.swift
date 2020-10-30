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
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var chooseImageButton: UIButton!
    @IBOutlet private var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var postButton: UIBarButtonItem!
    
    @IBOutlet private var filterImageButton: UIButton!
    @IBOutlet private var filterAgainButton: UIButton!
    @IBOutlet private var clearFiltersButton: UIButton!
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    var originalImage: UIImage? {
        didSet {
            filterImageButton.isHidden = false
        }
    }
    var filteredImage: UIImage? {
        didSet {
            self.filterImageButton.isHidden = true
            self.filterAgainButton.isHidden = false
            self.clearFiltersButton.isHidden = false
            self.imageView.image = self.filteredImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageViewHeight(with: 1.0)
        filterImageButton.isHidden = true
        filterAgainButton.isHidden = true
        clearFiltersButton.isHidden = true
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
    
    @IBAction func filterImage(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let filterVC = storyBoard.instantiateViewController(withIdentifier: "ImageFilterViewController") as! ImageFilterViewController
        filterVC.originalImage = originalImage
        filterVC.delegate = self
        self.present(filterVC, animated: true, completion: nil)
    }
    
    @IBAction func filterAgain(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let filterVC = storyBoard.instantiateViewController(withIdentifier: "ImageFilterViewController") as! ImageFilterViewController
        filterVC.originalImage = originalImage
        filterVC.filteredImage = filteredImage
        filterVC.delegate = self
        self.present(filterVC, animated: true, completion: nil)
    }
    
    @IBAction func clearFilters(_ sender: UIButton) {
        filteredImage = nil
        imageView.image = originalImage
        filterImageButton.isHidden = false
        filterAgainButton.isHidden = true
        clearFiltersButton.isHidden = true
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        originalImage = image
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagePostViewController: FilterVCDelegate {
    func updateImage(originalImage: UIImage, filteredImage: UIImage?) {
        self.originalImage = originalImage
        self.filteredImage = filteredImage
    }
}
