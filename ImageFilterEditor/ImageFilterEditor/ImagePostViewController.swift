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
    private var originalImage: UIImage?
    private var scaledImage: UIImage?
    
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
       
       
    }


}

