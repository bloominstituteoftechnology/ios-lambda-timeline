//
//  AddFiltersViewController.swift
//  LambdaTimeline
//
//  Created by Jake Connerly on 10/29/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreImage

class AddFiltersViewController: UIViewController {
    
    // MARK: - IBOutlets & Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var sepiaSlider: UISlider!
    @IBOutlet weak var twirlRadiusSlider: UISlider!
    @IBOutlet weak var twirlAngleSlider: UISlider!
    
    private let context = CIContext(options: nil)
    
    private let blurFilter = CIFilter(name: "CIBoxBlur")!
    private let sepiaFilter = CIFilter(name: "CISepiaTone")!
    private let twirlFilter = CIFilter(name: "CITwirlDistortion")!
    
    var image: UIImage?
    
    var originalImage: UIImage? {
        didSet {
                guard let image = originalImage else { return }
                imageView.image = image
                var scaledSize = imageView.bounds.size // gets the physical number of pixels on screen
                
                // 1x 2x 3x
                let scale = UIScreen.main.scale
                
                scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
                scaledImage = image.imageByScaling(toSize: scaledSize)
        }
    }

    var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }

    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        originalImage = image
    }
    
    // MARK: - IBActions & Methods
    
    private func filterImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        blurFilter.setValue(ciImage, forKey: "inputImage")
        blurFilter.setValue(blurSlider.value, forKey: "inputRadius")
        guard let outputCIImageWithBlur = blurFilter.outputImage else { return nil }
        
        sepiaFilter.setValue(outputCIImageWithBlur, forKey: "inputImage")
        sepiaFilter.setValue(sepiaSlider.value, forKey: "inputIntensity")
        guard let outputCIImageWithSepia = sepiaFilter.outputImage else { return nil }
        
        twirlFilter.setValuesForKeys(["inputImage": outputCIImageWithSepia,
                                       "inputCenter": CIVector(x: 150, y: 150),
                                       "inputRadius": twirlRadiusSlider.value,
                                       "inputAngle": twirlAngleSlider.value])
        guard let outputCIImageWithTwirl = twirlFilter.outputImage else {
            print("Failed adding twirl")
            return nil
        }
        
        
        // render the image
        guard let outputCGImage = context.createCGImage(outputCIImageWithTwirl, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
        private func updateImage() {
        if let image = scaledImage {
            imageView.image = filterImage(image: image)
        }
    }
    
    @IBAction func blurSliderDidChangeValue(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func sepiaSliderDidChangeValue(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func twirlRadiusDidChangeValue(_ sender: UISlider) {
        updateImage()
    }
    @IBAction func twirlAngleDidChangeValue(_ sender: UISlider) {
        updateImage()
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        guard let image = imageView.image else { return }
        NotificationCenter.default.post(name: .doneApplyingFilters, object: self, userInfo: ["image": image])
    }
}
