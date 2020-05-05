//
//  FilterPhotoViewController.swift
//  FilteringStoryboard
//
//  Created by Ezra Black on 5/5/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit
import CoreImage


class FilterPhotoViewController: UIViewController {
    
    //MARK- Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var chooseFilter: UIButton!
    @IBOutlet weak var savePhoto: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK- Actions
    
  
    @IBAction func chooseFilterTapped(_ sender: UIButton) {
    }
    
    @IBAction func savePhotoTapped(_ sender: UIButton) {
    }
    
    @IBAction func choosePhotoTapped(_ sender: Any) {
    }
    
}


