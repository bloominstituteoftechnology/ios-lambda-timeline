//
//  ImageViewController.swift
//  ImageFilterEditor
//
//  Created by Alex Thompson on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreImage

enum FilterType: Int {
    case exposure
    case vibrance
    case vignette
    case sepia
    case motionBlur
}

class ImageViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var adjustmentSlider: UISlider!
    @IBOutlet var secondAdjustmentSlider: UISlider!
    @IBOutlet var saveButton: UIButton!
    
    let context = CIContext(options: nil)
    var filterType: FilterType = .exposure
    let effectNames: [String] = ["Exposure",
                                 "Vibrance",
                                 "Vignette",
                                 "Sepia Tone",
                                 "Motion Blur"
    ]
    
    let effectImages: [UIImage] = [UIImage(systemName: "sun.max")!,
                                   UIImage(systemName: "sunrise")!,
                                   UIImage(systemName: "smallcircle.circle")!,
                                   UIImage(systemName: "eyedropper.halffull")!,
                                   UIImage(systemName: "slider.horizontal.3")!
    ]
    
    var originalImage: UIImage? {
        didSet {
            //resize the scaledImage
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondAdjustmentSlider.isHidden = true
        adjustmentSlider.isHidden = true
        nameLabel.isHidden = true
        saveButton.isHidden = true
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        presentImagePickerController()
    }
    
    @IBAction func slider1Changed(_ sender: Any) {
        updateViews(withAdjustment: true)
    }
    
    @IBAction func slider2Changed(_ sender: Any) {
        updateViews(withAdjustment: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        scaledImage = imageView.image
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Photo library unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateViews(withAdjustment: Bool = false) {
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
    }
    
    private func adjustExposure(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIExposureAdjust")!
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputEVKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustVibrance(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        //filter
        let filter = CIFilter(name: "CIVibrance")!
        
        // Trying to get values from core image
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputAmountKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustVignette(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        //filter
        let filter = CIFilter(name: "CIVignetteEffect")!
        
        //getting values from core image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputIntensityKey)
        filter.setValue(secondAdjustmentSlider.value, forKey: kCIInputRadiusKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustSepia(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // filter
        let filter = CIFilter(name: "CISepiaTone")!
        
        //getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputIntensityKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustMotionBlur(_ image: UIImage) -> UIImage? {
    
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        //filter
        let filter = CIFilter(name: "CIMotionBlur")!
        
        //getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputRadiusKey)
        filter.setValue(secondAdjustmentSlider.value, forKey: kCIInputAngleKey)
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func showFilter(for index: IndexPath) {
        adjustmentSlider.isHidden = false
        nameLabel.isHidden = false
        saveButton.isHidden = false
        
        nameLabel.text = effectNames[index.row]
        filterType = FilterType(rawValue: index.item)!
        imageView.image = scaledImage
        
        if index.item == 0 {
            secondAdjustmentSlider.isHidden = true
            
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 10
            adjustmentSlider.minimumValue = -10
       
        } else if index.item == 1 {
            secondAdjustmentSlider.isHidden = true
            
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 1
            adjustmentSlider.minimumValue = -1
            
        } else if index.item == 2 {
            secondAdjustmentSlider.isHidden = false
            
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 1
            adjustmentSlider.minimumValue = -1
            
            secondAdjustmentSlider.value = 0
            secondAdjustmentSlider.maximumValue = 2000
            secondAdjustmentSlider.minimumValue = 0
            
        } else if index.item == 3 {
            secondAdjustmentSlider.isHidden = true
            
            adjustmentSlider.value = 9
            adjustmentSlider.maximumValue = 1
            adjustmentSlider.minimumValue = 0
            
        } else if index.item == 4 {
            secondAdjustmentSlider.isHidden = false
            
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 100
            adjustmentSlider.minimumValue = 0
            
            secondAdjustmentSlider.value = 0
            secondAdjustmentSlider.maximumValue = 3.141592653589793
            secondAdjustmentSlider.minimumValue = -3.141592653589793
            
        }
    }
}

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effectNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        cell.layer.cornerRadius = 15
        cell.myLabel.text = effectNames[indexPath.item]
        cell.image.image = effectImages[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showFilter(for: indexPath)
    }
}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
