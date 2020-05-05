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
        
        let context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
  
    
    //MARK- Actions
    
  
    @IBAction func chooseFilterTapped(_ sender: Any) {
    }
    
    @IBAction func savePhotoTapped(_ sender: Any) {
    }

    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          guard let image = info[.editedImage] as? UIImage else { return}
          dismiss(animated: true)
          currentImage = image
          
          let beginImage = CIImage(image: currentImage)
          currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

          applyProcessing()
      }
      
      @objc func importPicture() {
          let picker = UIImagePickerController()
          picker.allowsEditing = true
          picker.delegate = self
          present(picker, animated: true)
      }
    
    func applyProcessing() {
        guard let image = currentFilter.outputImage else { return }
        currentFilter.setValue(valueSlider.value, forKey: kCIInputIntensityKey)

        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
    }
}


