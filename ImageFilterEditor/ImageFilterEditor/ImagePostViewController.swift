//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Joshua Rutkowski on 5/6/20.
//  Copyright © 2020 Josh Rutkowski. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class ImagePostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: Properties
    var context: CIContext = CIContext(options: nil)
    var appliedFilter: CIFilter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if imageView.image == nil {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func actionClickOnCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true;
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Alert", message: "There appears to be a problem with the camera on your device.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    
    @IBAction func actionClickOnGallery(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true;
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    
    @IBAction func actionFilter(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Vignette", style: .default, handler: handleFilterSelection))
        actionSheet.addAction(UIAlertAction(title: "Film Noir", style: .default, handler: handleFilterSelection))
        actionSheet.addAction(UIAlertAction(title: "Black and White", style: .default, handler: handleFilterSelection))
        actionSheet.addAction(UIAlertAction(title: "Sepia", style: .default, handler: handleFilterSelection))
        actionSheet.addAction(UIAlertAction(title: "Warm Colors", style: .default, handler: handleFilterSelection))
        actionSheet.addAction(UIAlertAction(title: "Custom", style: .default, handler: presentCustomFilterDetail))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func savePhotoButtonPressed(_ sender: Any) {
        if let pickedImage = imageView.image {
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, #selector(saveImageToLibrary(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
    }
    @objc func saveImageToLibrary (_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your filtered image has been saved to your Photos Library.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    
    //MARK: -  Helper functions
    func handleFilterSelection(action: UIAlertAction!) {
        
        var actionTitle = action.title
        
        switch actionTitle {
        case "Vignette":
            actionTitle = "CIVignette"
        case "Film Noir":
            actionTitle = "CIPhotoEffectNoir"
        case "Black and White":
            actionTitle = "CIPhotoEffectTonal"
        case "Sepia":
            actionTitle = "CISepiaTone"
        case "Warm Colors":
            actionTitle = "CIPhotoEffectTransfer"
        default:
            print("Error")
        }
        
        appliedFilter = CIFilter(name: actionTitle!)
        
        let beginImage = CIImage(image: imageView.image!)
        appliedFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyFilter()
    }
    
    func applyFilter() {
        let inputKeys = appliedFilter.inputKeys
        let intensity = 0.5
        
        if inputKeys.contains(kCIInputIntensityKey) { appliedFilter.setValue(intensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { appliedFilter.setValue(intensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { appliedFilter.setValue(intensity * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { appliedFilter.setValue(CIVector(x: imageView.image!.size.width / 2, y: imageView.image!.size.height / 2), forKey: kCIInputCenterKey) }
        
        guard let cgImage = context.createCGImage(appliedFilter.outputImage!, from: appliedFilter.outputImage!.extent) else { return }
        let filteredImage = UIImage(cgImage: cgImage, scale: self.imageView.image!.scale, orientation: self.imageView.image!.imageOrientation)
        
        self.imageView.image = filteredImage
    }
    
    func presentCustomFilterDetail(action: UIAlertAction!) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomFilterDetailViewController") as? CustomFilterDetailViewController
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] {
            imageView.image = image as? UIImage
        } else {
            print("Error accessing image.")
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
