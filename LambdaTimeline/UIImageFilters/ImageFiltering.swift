//
//  ImageFiltering.swift
//  LambdaTimeline
//
//  Created by Patrick Millet on 6/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

protocol PhotoFinishedEditing {
    func photoFinishedEditing(image: UIImage)
}

class ImageFiltering: UIViewController {
    
    var delegate: PhotoFinishedEditing?
    
    private let context = CIContext(options: nil)
    
    var originalImage: UIImage? {
        didSet {
            
            guard isViewLoaded else { return }
            
            guard let originalImage = originalImage else {
                scaledImage = nil // clear out image if original image fails
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale,
                                height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sharpnessSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imageView.image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        brightnessSlider.value = 0
        contrastSlider.value = 1
        saturationSlider.value = 1
        blurSlider.value = 1
        sharpnessSlider.value = 0.4
    }
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Filtering
        let filter = CIFilter.colorControls() // May not work for some custom filters (KVC protocol)
        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        
        // CIImage -> CGImage -> UIImage
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Takes in the color filters and adds a blur filter
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = outputCIImage
        blurFilter.radius = blurSlider.value
        
        guard let blurFilterImage = blurFilter.outputImage else { return nil }
        
        // Applies a sharpen filter to the image
        
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = blurFilterImage
        sharpenFilter.sharpness = sharpnessSlider.value
        
        guard let sharpenFilterImage = sharpenFilter.outputImage else { return nil }
        
        //Render image
        guard let outputCGImage = context.createCGImage(sharpenFilterImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func updateViews() {
        guard let scaledImage = scaledImage else { return }
        imageView.image = filterImage(scaledImage)
    }
    
    // MARK: Actions
    
    @IBAction func savePhotoButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Save to photo library
        saveAndFilterPhoto()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func saveAndFilterPhoto() {
        
        //TODO: Use a delegate to pass the filtered photo to the postVC
        guard let originalImage = originalImage else { return }
        
        guard let filteredImage = filterImage(originalImage) else { return }
        
        
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else { return }
        }
        
        PHPhotoLibrary.shared().performChanges({
            
            PHAssetCreationRequest.creationRequestForAsset(from: filteredImage)
            
        }) { (success, error) in
            if let error = error {
                print("Error saving photo: 😢 \(error)")
                return
            }
            DispatchQueue.main.async {
                print("Saved photo")
            }
        }
        
        delegate?.photoFinishedEditing(image: originalImage)
    }
    
    
    // MARK: Slider events
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateViews()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func blurChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func sharpnessChanged(_ sender: Any) {
        updateViews()
    }
}
