//
//  FilterPhotoViewController.swift
//  FilteringStoryboard
//
//  Created by Ezra Black on 5/5/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit
import CoreImage


class FilterPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK- Properties
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var savePhoto: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FilterImager"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))

    }
    
    @objc func importPicture() {
        
    }
    
    //MARK- Actions
    
  
    @IBAction func chooseFilterTapped(_ sender: UIButton) {
    }
    
    @IBAction func savePhotoTapped(_ sender: UIButton) {
    }
    
}


