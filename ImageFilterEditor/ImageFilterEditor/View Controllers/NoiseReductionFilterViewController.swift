//
//  NoiseReductionFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Jessie Ann Griffin on 5/8/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit

protocol NoiseFilterProtocol {
    func applyNoiseFilter() -> CIFilter
    
    var noise: Double { get }
    var sharpness: Double { get }
}

class NoiseReductionFilterViewController: UIViewController {

    @IBOutlet weak var noiseFilterSlider: UISlider!
    @IBOutlet weak var sharpnessFilterSlider: UISlider!
    
    var noiseDelegate: NoiseFilterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

//    private func image(byFiltering inputImage: CIImage) -> UIImage {
//        
//        colorControlsFilter.inputImage = inputImage
//        colorControlsFilter.saturation = saturationSlider.value
//        colorControlsFilter.brightness = brightnessSlider.value
//        colorControlsFilter.contrast = contrastSlider.value
//        
//        blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
//        blurFilter.radius = blurSlider.value
//        
//        guard let outputImage = blurFilter.outputImage else { return originalImage! }
//        
//        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
//        
//        return UIImage(cgImage: renderedImage)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
