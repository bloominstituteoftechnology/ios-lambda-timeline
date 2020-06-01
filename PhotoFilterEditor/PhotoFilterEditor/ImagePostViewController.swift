//
//  ImagePostViewController.swift
//  PhotoFilterEditor
//
//  Created by Bhawnish Kumar on 6/1/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {

    private var originalImage: UIImage?
    @IBOutlet weak var choosePhotoOutlet: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var blurRadiusSlider: UISlider!
    @IBOutlet weak var bumpRadiusSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choosePhotoOutlet.layer.cornerRadius = 12
        // Do any additional setup after loading the view.
        let filter = CIFilter.colorControls()
        filter.brightness = 1
        print(filter.attributes)
        
        originalImage = imageView.image
    }
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.colorControls()
        filter.brightness = 1
        filter.saturation = 1
        filter.contrast = 1
        filter.inputImage = ciImage
        
        
        return nil
    }
    
    @IBAction func brightnessSlider(_ sender: UISlider) {
    }
    
    @IBAction func contrastSlider(_ sender: UISlider) {
    }
    
    @IBAction func saturationSlider(_ sender: UISlider) {
    }
    @IBAction func blurRadiusSlider(_ sender: UISlider) {
    }
    
    @IBAction func bumpRadiusSlider(_ sender: UISlider) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
