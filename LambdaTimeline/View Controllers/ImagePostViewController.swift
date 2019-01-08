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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    func updateViews() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 500
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
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
            let title = imageDescription, title != "" else {
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
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var offset: CGFloat = 0
    
    // MARK:- Current filter settings
    var imageDescription: String? = nil
    var isBeautifyDisabled: Bool = true
    var isBeautifyOn: Bool = false
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            // Height and width
            var scaledSize = imageView.bounds.size
            // 1x, 2x, or 3x
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize) ?? originalImage
        }
    }
    
    var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    private let context = CIContext(options: nil)
    private let beautifyFilter = CIFilter(name: "YUCISurfaceBlur")!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        chooseImageButton.backgroundColor = .clear
        chooseImageButton.frame = imageView.frame
        view.layoutSubviews()
        
        picker.dismiss(animated: true, completion: nil)
        
        isBeautifyDisabled = false
        isBeautifyOn = false
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        originalImage = image
        
        tableView.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension ImagePostViewController: UITableViewDataSource, UITableViewDelegate, ImageDetailsCellDelegate {
    
    
    func textFieldBeganEditing(textFieldText: String) {
        offset = tableView.contentOffset.y - 166.0
        tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: 166.0), animated: true)
        tableView.isUserInteractionEnabled = false
    }
    
    func textFieldTextChanged(to text: String) {
        imageDescription = text
    }
    
    func textFieldEndedEditing() {
        tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + offset), animated: true)
        tableView.isUserInteractionEnabled = true
    }
    
    func beautifyButtonPressed() {
        isBeautifyOn = !isBeautifyOn
        updateImage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageDetailsCell", for: indexPath) as? ImageDetailsCell else { return UITableViewCell() }
        
        cell.delegate = self
        cell.isBeautifyDisabled = self.isBeautifyDisabled
        cell.isBeautifyOn = self.isBeautifyOn
        
        return cell
    }
    
}


// Image filtering
extension ImagePostViewController {
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            if isBeautifyOn && !isBeautifyDisabled {
                let beautyImage = beautifyImage(byFiltering: scaledImage)
                imageView.image = filterImage(byFiltering: beautyImage)
            } else {
                imageView.image = filterImage(byFiltering: scaledImage)
            }
        } else {
            imageView.image = originalImage
        }
    }
    
    private func beautifyImage(byFiltering image: UIImage) -> UIImage {
        let image = image.fixOrientation()
        
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        // Set the value of the filter's parameters
        beautifyFilter.setValue(ciImage, forKey: "inputImage")
        beautifyFilter.setValue(4, forKey: "inputRadius")
        
        // The metadata to be processed
        guard let outputCIImage = beautifyFilter.outputImage else { return image }
        // The rendered Core Graphics image data
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        // Return the UIImage version of the filtered CGImage
        return UIImage(cgImage: outputCGImage)
    }
    
    private func filterImage(byFiltering image: UIImage) -> UIImage {
        return image
    }
}
