//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Hunter Oppel on 6/1/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var guassianBlurSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var hueSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let guassianFilter = CIFilter.gaussianBlur()
        let colorControlsFilter = CIFilter.colorControls()
        let twirlFilter = CIFilter.hueAdjust()
        
        print(guassianFilter.attributes)
        print("================================")
        print(colorControlsFilter.attributes)
        print("================================")
        print(twirlFilter.attributes)
        
        // Setting this manually because the storyboard didn't play nice with the numbers
        hueSlider.minimumValue = -3.141592653589793
        hueSlider.maximumValue = 3.141592653589793
    }

    @IBAction func choosePhoto(_ sender: Any) {
    }
    
    @IBAction func resetValues(_ sender: Any) {
    }
    
    @IBAction func savePhoto(_ sender: Any) {
    }
    
}

