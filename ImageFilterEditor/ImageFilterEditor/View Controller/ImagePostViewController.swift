//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Wyatt Harrell on 5/4/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import CoreImage

// TODO: Add labels to sliders
// TODO: fit sliders in view better
// TODO: adjust edited image not original

enum FilterTypes: Int {
    case exposure
    case vibrance
    case vignette
}

class ImagePostViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var adjustmentSlider: UISlider!
    
    @IBOutlet weak var secondAdjustmentSlider: UISlider!
    
    // MARK: - Properties
    let context = CIContext(options: nil)
    var filterType: FilterTypes = .exposure
    let effectNames: [String] = ["Exposure", "Vibrance", "Vignette"]
    let effectImages: [UIImage] = [UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!]
    
    var originalImage: UIImage? {
        didSet {
            // resize the scaledImage and set it
            guard let originalImage = originalImage else { return }
            // Height and width
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale  // 1x, 2x, or 3x
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            print("scaled size: \(scaledSize)")
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        secondAdjustmentSlider.isHidden = true
        
        let filter = CIFilter(name: "CIVignetteEffect")! // Built-in filter from Apple
        print(filter)
        print(filter.attributes)
    }
    
    // MARK: - IBActions
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        presentImagePickerController()
    }
    
    @IBAction func adjustmentSliderChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func secondAdjustmentSliderChanged(_ sender: Any) {
        updateViews()
    }
    
    // MARK: - Private Methods
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateViews() {
        if let scaledImage = scaledImage {
            
            if filterType.rawValue == 0 {
                imageView.image = adjustExposure(scaledImage)
            } else if filterType.rawValue == 1 {
                imageView.image = adjustVibrance(scaledImage)
            } else if filterType.rawValue == 2 {
                imageView.image = adjustVignette(scaledImage)
            }
            
        } else {
            imageView.image = nil
        }
    }
    
    private func adjustExposure(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // Filter
        let filter = CIFilter(name: "CIExposureAdjust")!
        
        // Setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputEVKey)
        
        // CIImage -> CGImage -> UIImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (do image processing here). Recipe needs to be used on image now.
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustVibrance(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // Filter
        let filter = CIFilter(name: "CIVibrance")!
        
        // Setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputAmountKey)
        
        // CIImage -> CGImage -> UIImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (do image processing here). Recipe needs to be used on image now.
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustVignette(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // Filter
        let filter = CIFilter(name: "CIVignetteEffect")!
        
        // Setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputIntensityKey)
        filter.setValue(secondAdjustmentSlider.value, forKey: kCIInputRadiusKey)
        
        // CIImage -> CGImage -> UIImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (do image processing here). Recipe needs to be used on image now.
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }

}

extension ImagePostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effectNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCell", for: indexPath) as? EffectCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = 15
        cell.nameLabel.text = effectNames[indexPath.item]
        cell.effectImage.image = effectImages[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        nameLabel.text = effectNames[indexPath.row]
        filterType = FilterTypes(rawValue: indexPath.item)!
        
        // TODO: Add all of this to own function

        if indexPath.item == 0 {
            secondAdjustmentSlider.isHidden = true
            
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 10
            adjustmentSlider.minimumValue = -10
        } else if indexPath.item == 1 {
            secondAdjustmentSlider.isHidden = true
            
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 1
            adjustmentSlider.minimumValue = -1
        } else if indexPath.item == 2 {
            secondAdjustmentSlider.isHidden = false

            // Intensity
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 1
            adjustmentSlider.minimumValue = -1
            
            // Radius
            secondAdjustmentSlider.value = 0
            secondAdjustmentSlider.maximumValue = 2000
            secondAdjustmentSlider.minimumValue = 0
        }
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
