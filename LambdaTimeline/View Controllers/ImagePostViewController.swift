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

enum FilterType: Int {
    case exposure
    case vibrance
    case vignette
    case sepia
    case motionBlur
}

@available(iOS 13.0, *)
@available(iOS 13.0, *)

class ImagePostViewController: ShiftableViewController {
    
    let context = CIContext(options: nil)
    var filterType: FilterType = .exposure
    let effectNames: [String] = ["Exposure",
                                 "Vibrance",
                                 "Vignette",
                                 "Sepia Tone",
                                 "Motion Blur"]
                                    
    
    let effectImages: [UIImage] = [UIImage(systemName: EffectNames.exposure.rawValue)!,
                                   UIImage(systemName: EffectNames.vibrance.rawValue)!,
                                   UIImage(systemName: EffectNames.vignette.rawValue)!,
                                   UIImage(systemName: EffectNames.sepiaTone.rawValue)!,
                                   UIImage(systemName: EffectNames.motionBlur.rawValue)!]
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.width * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    func hideViews() {
        slider1.isHidden = true
        slider2.isHidden = true
        nameLabel.isHidden = true
        saveFilterButton.isHidden = true
//        myCollectionView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        hideViews()
        updateViews()
    }
    
    @IBAction func adjustmentSliderChanged(_ sender: Any) {
        updateViews(withAdjustment: true)
    }
    
    @IBAction func adjustmentSlider2Changed(_ sender: Any) {
        updateViews(withAdjustment: true)
    }
    
    @IBAction func filterSavedTapped(_ sender: Any) {
        scaledImage = imageView.image
    }
    
    func updateViews(withAdjustment: Bool = false) {
        
        if let scaledImage = scaledImage {
            
            if withAdjustment {
                if filterType.rawValue == 0 {
                    imageView.image = adjustExposure(scaledImage)
                } else if filterType.rawValue == 1 {
                    imageView.image = adjustVibrance(scaledImage)
                } else if filterType.rawValue == 2 {
                    imageView.image = adjustVignette(scaledImage)
                } else if filterType.rawValue == 3 {
                    imageView.image = adjustSepia(scaledImage)
                } else if filterType.rawValue == 4 {
                    imageView.image = adjustMotionBlur(scaledImage)
                }
            } else {
                imageView.image = scaledImage
            }
        } else {
            imageView.image = nil
        }
        
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
    
    private func adjustExposure(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil}
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIExposureAdjust")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputEVKey)
        
        guard let outputCIImage = filter.outputImage else { return nil}
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustVibrance(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIVibrance")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputAmountKey)
        
        guard let outputCIImage = filter.outputImage else { return nil}
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustVignette(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIVignetteEffect")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputIntensityKey)
        filter.setValue(slider2.value, forKey: kCIInputRadiusKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustSepia(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputIntensityKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustMotionBlur(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIMotionBlur")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputRadiusKey)
        filter.setValue(slider2.value, forKey: kCIInputAngleKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func showFilter(for index: IndexPath) {
            slider1.isHidden = false
            nameLabel.isHidden = false
            saveFilterButton.isHidden = false
            
            nameLabel.text = effectNames[index.row]
            filterType = FilterType(rawValue: index.item)!
            imageView.image = scaledImage
            
            if index.item == 0 {
                slider2.isHidden = true
                
                slider1.value = 0
                slider1.maximumValue = 10
                slider1.minimumValue = -10
           
            } else if index.item == 1 {
                slider2.isHidden = true
                
                slider1.value = 0
                slider1.maximumValue = 1
                slider1.minimumValue = -1
                
            } else if index.item == 2 {
                slider2.isHidden = false
                
                slider1.value = 0
                slider1.maximumValue = 1
                slider1.minimumValue = -1
                
                slider2.value = 0
                slider2.maximumValue = 2000
                slider2.minimumValue = 0
                
            } else if index.item == 3 {
                slider2.isHidden = true
                
                slider1.value = 9
                slider1.maximumValue = 1
                slider1.minimumValue = 0
                
            } else if index.item == 4 {
                slider2.isHidden = false
                
                slider1.value = 0
                slider1.maximumValue = 100
                slider1.minimumValue = 0
                
                slider2.value = 0
                slider2.maximumValue = 3.141592653589793
                slider2.minimumValue = -3.141592653589793
        }
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
    
    
    func setImageRatio(with scaling: CGSize) {
        imageHeightConstraint.constant = imageView.frame.size.width
        
        view.layoutSubviews()
    }
    
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var saveFilterButton: UIButton!
}

@available(iOS 13.0, *)
extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        originalImage = image
        imageView.image = originalImage
        //myCollectionView.isHidden = false
        setImageRatio(with: image.size)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

@available(iOS 13.0, *)
extension ImagePostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effectNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as? MyCollectionViewCell else { return UICollectionViewCell() }
        
        cell.layer.cornerRadius = 15
        cell.myLabel.text = effectNames[indexPath.item]
        cell.image.image = effectImages[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showFilter(for: indexPath)
    }
}
