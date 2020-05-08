//
//  ImageFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Christy Hicks on 5/6/20.
//  Copyright © 2020 Knight Night. All rights reserved.
//

import UIKit

class ImageFilterViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var saturationSlider: UISlider!
    @IBOutlet var brightnessSlider: UISlider!
    @IBOutlet var contrastSlider: UISlider!
    @IBOutlet var exposureSlider: UISlider!
    
    // MARK: - Properties
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    // MARK: - Actions
    @IBAction func choosePhoto(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func invertColors(_ sender: UIButton) {
        
    }
    
    @IBAction func greyscale(_ sender: UIButton) {
        
    }
    
    @IBAction func savePhoto(_ sender: UIButton) {
        
    }
    
    // MARK: - Methods
}

