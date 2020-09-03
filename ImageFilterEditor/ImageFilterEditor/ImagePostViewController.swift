//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Morgan Smith on 9/2/20.
//  Copyright © 2020 Morgan Smith. All rights reserved.
//

import UIKit
import CoreImage
import Photos
import CoreImage.CIFilterBuiltins

class ImagePostViewController: UIViewController {

     var imageData: Data?
    var filteredImage: UIImage?

     @IBOutlet weak var imageView: UIImageView!
     @IBOutlet weak var titleTextField: UITextField!
     @IBOutlet weak var chooseImageButton: UIBarButtonItem!
     @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
     @IBOutlet weak var postButton: UIBarButtonItem!

    static var sharedPhoto = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let filtered = filteredImage {
            imageView.image = filtered
        } else {
             updateViews()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let filtered = filteredImage {
                   imageView.image = filtered
               } else {
                    updateViews()
               }
    }

    func updateViews() {
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        title = "New Title"
        imageView.image = image
    }


    @IBAction func filterPhoto(_ sender: Any) {
        ImagePostViewController.sharedPhoto = imageView.image ?? UIImage(systemName: "photo")!
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
    


    // MARK: - Navigation

}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {


        picker.dismiss(animated: true, completion: nil)

        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }

        imageView.image = image

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

