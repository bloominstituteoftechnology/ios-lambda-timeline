//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Waseem Idelbi on 9/2/20.
//  Copyright © 2020 Waseem Idelbi. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

class ViewController: UIViewController {
    
    //MARK: - IBOutlets and Properties -
    
    private let bokehBlur = CIFilter.bokehBlur()
    
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func filterBokehBlur(inputImage: CIImage, inputRadius: NSNumber, inputRingAmount: NSNumber, inputRingSize: NSNumber, inputSoftness: NSNumber) {
        
        
        
    }
    
    @IBAction func bokehBlurFilterButtonTapped(_ sender: UIButton) {
        filterBokehBlur(inputImage: CIImage(image: imageView.image!)!, inputRadius: 30, inputRingAmount: 1, inputRingSize: 7, inputSoftness: 0)
    }
    
}

