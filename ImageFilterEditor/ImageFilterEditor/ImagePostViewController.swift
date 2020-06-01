//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/1/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {
    
    // MARK: - Properites
    private let context = CIContext(options: nil)
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else {
                scaledImage = nil
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    private var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var posterizeSlider: UISlider!
    @IBOutlet weak var sepiaSlider: UISlider!
    @IBOutlet weak var sharpnessSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var monoSlider: UISlider!
    @IBOutlet weak var chromeSlider: UISlider!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       originalImage = imageView.image
    }
    
    private func updateViews() {
       if let scaledImage = scaledImage {
           imageView.image = posterizeImage(scaledImage)
       } else {
           imageView.image = nil
    }
    }
    
    @IBAction func posterizeChanged(_ sender: Any) {
        updateViews()
    }
    
    func posterizeImage(_ image: UIImage) -> UIImage? {
           
           // UIImage > CGImage > CIImage
           guard let cgImage = image.cgImage else { return nil }
           let ciImage = CIImage(cgImage: cgImage)
           let filter = CIFilter.colorPosterize()
           filter.inputImage = ciImage
           filter.levels = posterizeSlider.value
           
           guard let outputCIImage = filter.outputImage else { return nil }
               
           // Render the image (apply the filter to the image) i.e. baking the cookies in the over
           guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
               // CIImage > CGImage > UIImage
           return UIImage(cgImage: outputCGImage)
       }
}

