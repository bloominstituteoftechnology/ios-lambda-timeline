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
    
    let context = CIContext()
    var filterType: FilterType = .exposure
    let effextNames: [String] = ["Exposure",
                                 "Vibrance",
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
            scaledSize = CGSize(width: scaledSize.width, height: scaledSize.width * scale)
            
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
        
    }
    
    @IBAction func slider1Changed(_ sender: Any) {
        
    }
    
    @IBAction func slider2Changed(_ sender: Any) {
        
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
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
}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
