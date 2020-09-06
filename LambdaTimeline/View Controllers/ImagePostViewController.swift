//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class ImagePostViewController: ShiftableViewController {
    
    @IBOutlet weak var editPhoto: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var filteredImage: UIImage?
    var originalImagePost: UIImage? {
        didSet {
            print("set the original image in postController")
            viewDidLoad()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let filteredImage = filteredImage {
            setImageViewHeight(with: filteredImage.ratio)
            imageView.image = filteredImage
            editPhoto.setTitle("Edit Photo", for: .normal)
            editPhoto.setTitleColor(.systemBlue, for: .normal)
            title = "New Post"
            chooseImageButton.setTitle("", for: [])
        } else {
            setImageViewHeight(with: 1.0)
            updateViews()
        }
    }
    
    func updateViews() {
        editPhoto.setTitle("Edit Photo", for: .normal)
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                editPhoto.setTitleColor(.white, for: .normal)
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        editPhoto.setTitleColor(.systemBlue, for: .normal)
        
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
            let title = titleTextField.text, title != "", let ratio = imageView.image?.ratio else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: ratio) { (success) in
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
    
    @IBAction func editPhoto(_ sender: Any) {
    }
    
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPhotoSegue" {
            if let tabController = segue.destination as? UITabBarController {
                let blurController = tabController.children.first(where: { $0 is BlurViewController })
                (blurController as? BlurViewController)?.originalImagePost = self.originalImagePost
                
                let colorController = tabController.children.first(where: { $0 is ColorViewController })
                (colorController as? ColorViewController)?.originalImagePost = self.originalImagePost
                
                let distortionController = tabController.children.first(where: { $0 is DistortionViewController })
                (distortionController as? DistortionViewController)?.originalImagePost = self.originalImagePost
                let sharpenController = tabController.children.first(where: { $0 is SharpenViewController })
                (sharpenController as? SharpenViewController)?.originalImagePost = self.originalImagePost
                let colorInvertController = tabController.children.first(where: { $0 is ColorInvertViewController })
                (colorInvertController as? ColorInvertViewController)?.originalImagePost = self.originalImagePost
                
                
                
                
                
            }
        }
    }
    
    
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        originalImagePost = image
        
        setImageViewHeight(with: image.ratio)
        
        editPhoto.setTitleColor(.systemBlue, for: .normal)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
