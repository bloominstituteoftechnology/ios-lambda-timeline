//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

enum ImageFilterOption {
    case vibrance
    case posterize
    case colorInvert
    case comicEffect
}
class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                //isFilterOptionsHidden(true)
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
    
    @IBAction func posterizeChanged(_ sender: UISlider) {
        updateImage(.posterize)
    }
    
    @IBAction func vibranceChanged(_ sender: UISlider) {
        updateImage(.vibrance)
    }
    @IBAction func colorInvertChanged(_ sender: Any) {
        updateImage(.colorInvert)
    }
    
    @IBAction func comicEffectChanged(_ sender: UISwitch) {
        updateImage(.comicEffect)
    }
    
    private func scaleImage(_ image: UIImage) -> UIImage {

        var scaledSize = imageView.bounds.size
        // 1x, 2x, or 3x
        let scale = UIScreen.main.scale
        scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
        // returning scaled image
        return image.imageByScaling(toSize: scaledSize) ?? UIImage()
    }
    
    private func updateImage(_ filterOption: ImageFilterOption) {
        guard let image = imageView.image else { return }
        let scaledImage = scaleImage(image)

        switch filterOption {
        case .vibrance:
            imageView.image = vibranceImage(scaledImage)
        case .posterize:
            imageView.image = posterizeImage(scaledImage)
        case .colorInvert:
            imageView.image = colorInvertImage(scaledImage)
        case .comicEffect:
            imageView.image = comicEffectImage(scaledImage)
        }
    }

    // MARK: - Image filter option functions
       private func vibranceImage(_ image: UIImage) -> UIImage {
           guard let cgImage = image.cgImage,
               let vibranceFilter = vibranceFilter else { return image }

           let ciImage = CIImage(cgImage: cgImage)

           vibranceFilter.setValue(ciImage, forKey: "inputImage")
           vibranceFilter.setValue(vibranceSlider.value, forKey: kCIInputAmountKey)

           guard let outputCIImage = vibranceFilter.outputImage else { return image }

           guard let outputCGImage = context.createCGImage(outputCIImage,
                                                           from: CGRect(origin: CGPoint.zero, size: image.size))
               else { return image }

           return UIImage(cgImage: outputCGImage)
       }

    
    private func posterizeImage(_ image: UIImage) -> UIImage {
           guard let cgImage = image.cgImage,
               let posterizeFilter = posterizeFilter else { return image }

           let ciImage = CIImage(cgImage: cgImage)

           posterizeFilter.setValue(ciImage, forKey: "inputImage")
           posterizeFilter.setValue(posterizeSlider.value, forKey: "inputLevels")

           guard let outputCIImage = posterizeFilter.outputImage else { return image }

           guard let outputCGImage = context.createCGImage(outputCIImage,
                                                           from: CGRect(origin: CGPoint.zero, size: image.size))
               else { return image }

           return UIImage(cgImage: outputCGImage)
       }
    
    private func colorInvertImage(_ image: UIImage) -> UIImage {
           guard let cgImage = image.cgImage,
               let colorInvertFilter = colorInvertFilter else { return image }

           let ciImage = CIImage(cgImage: cgImage)

           colorInvertFilter.setValue(ciImage, forKey: "inputImage")

           guard let outputCIImage = colorInvertFilter.outputImage else { return image }

           guard let outputCGImage = context.createCGImage(outputCIImage,
                                                           from: CGRect(origin: CGPoint.zero, size: image.size))
               else { return image }

           return UIImage(cgImage: outputCGImage)
       }


    private func comicEffectImage(_ image: UIImage) -> UIImage {
           guard let cgImage = image.cgImage,
               let comicEffectFilter = comicEffectFilter else { return image }

           let ciImage = CIImage(cgImage: cgImage)

           comicEffectFilter.setValue(ciImage, forKey: "inputImage")

           guard let outputCIImage = comicEffectFilter.outputImage else { return image }

           guard let outputCGImage = context.createCGImage(outputCIImage,
                                                           from: CGRect(origin: CGPoint.zero, size: image.size))
               else { return image }

           return UIImage(cgImage: outputCGImage)
       }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    private var posterizeFilter = CIFilter(name: "CIColorPosterize")
    private var context = CIContext(options: nil)
    private var vibranceFilter = CIFilter(name: "CIVibrance")
    private var colorInvertFilter = CIFilter(name: "CIColorInvert")
    private var comicEffectFilter = CIFilter(name: "CIComicEffect")
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var posterizeSlider: UISlider!
    @IBOutlet weak var vibranceSlider: UISlider!
    @IBOutlet weak var colorInvertSwitch: UISwitch!
    @IBOutlet weak var comicEffectSwitch: UISwitch!
    
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
