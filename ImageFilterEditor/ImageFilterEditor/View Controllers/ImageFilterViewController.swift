//
//  ImageFilterViewController.swift
//  ImageFilterEditor
//
//  Created by denis cedeno on 5/7/20.
//  Copyright © 2020 DenCedeno Co. All rights reserved.
//

import UIKit
import Photos

class ImageFilterViewController: UIViewController {
    
    @IBAction func chooseImage(_ sender: Any) {
        presentImagePickerController()
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBAction func postImage(_ sender: Any) {
        savePhoto()
    }
    
    var photo: FilteredImage?
    private let photoController = FilteredImageController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
    }
    
    // MARK: - Private Methods
    
    @objc private func addImage() {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    return
                }
                self.presentImagePickerController()
            }
        default:
            break
        }
    }
    
    private func savePhoto() {
        guard let image = imageView.image,
            let imageData = image.pngData(),
            let comments = commentTextField.text else { return }
        photoController.appendFilteredImage(images: imageData, comments: comments)
        navigationController?.popViewController(animated: true)
    }
    
    private func updateViews() {
        guard let photo = photo else {
            title = "Add Image"
            return
        }
        title = photo.comments
        imageView.image = UIImage(data: photo.image!)
        commentTextField.text = photo.comments
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}


extension ImageFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
