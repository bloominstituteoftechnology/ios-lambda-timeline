//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Bradley Diroff on 6/1/20.
//  Copyright © 2020 Bradley Diroff. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {

    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func choosePhotoPressed(_ sender: UIButton) {
    }
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
    }
    
    @IBAction func contrastChanged(_ sender: UISlider) {
    }
    
    @IBAction func saturationChanged(_ sender: UISlider) {
    }
    
    @IBAction func savePhotoPressed(_ sender: UIButton) {
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
