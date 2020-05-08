//
//  ImageFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Jessie Ann Griffin on 5/7/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class ImageFilterViewController: UIViewController {

    var originalImage: UIImage?
    var scaledImage: CIImage?

    private let context = CIContext()
    private let noiseReductionFilter = CIFilter.noiseReduction()
    private let colorMatrixFilter = CIFilter.colorMatrix()
    private let whitePointAdjustmentFilter = CIFilter.whitePointAdjust()
    private let crystallizeFilter = CIFilter.crystallize()
    private let noirFilter = CIFilter.photoEffectNoir()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Image Filter Settings
    // CINoiseReduction: inputImage, inputNoiseLevel = 0.2, inputSharpness = 0.4
    // CIColorMatrix: inputImage, inputRVector [1 0 0 0], inputGVector [0 1 0 0], inputBVector [0 0 1 0]
    //                inputAVector [0 0 0 1], inputBiasVector [0 0 0 0]
    // CIWhitePointAdjust: inputImage, inputColor
    // CIDisplacementDistortion: inputImage, inputDisplacementImage (second image), inputScale = 50.0
    // CICrop: inputImage, inputRectangle
    // CICrystallize: inputImage, inputRadius, inputCenter
    // CIPhotoEffectNoir: inputImage

    private func image(byFiltering inputImage: CIImage) -> UIImage {

//        colorControlsFilter.inputImage = inputImage
//        colorControlsFilter.saturation = saturationSlider.value
//        colorControlsFilter.brightness = brightnessSlider.value
//        colorControlsFilter.contrast = contrastSlider.value
//
//        blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
//        blurFilter.radius = blurSlider.value

        guard let outputImage = blurFilter.outputImage else { return originalImage! }
        
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
        
        return UIImage(cgImage: renderedImage)
    }

    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }

    @IBAction func savePhotoButtonPressed(_ sender: UIButton) {
        guard let originalImage = originalImage?.flattened, let ciImage = CIImage(image: originalImage) else { return }
        
        let processedImage = self.image(byFiltering: ciImage)
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
            }) { (success, error) in
                if let error = error {
                    print("Error saving photo: \(error)")
                    //                    NSLog("%@", error)
                    return
                }
                
                DispatchQueue.main.async {
                    self.presentSuccessfulSaveAlert()
                }
            }
        }
    }
    
    private func presentSuccessfulSaveAlert() {
        let alert = UIAlertController(title: "Photo Saved!", message: "The photo has been saved to your Photo Library!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    

    // MARK: Slider events
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func blurChanged(_ sender: Any) {
        updateImage()
    }

}
