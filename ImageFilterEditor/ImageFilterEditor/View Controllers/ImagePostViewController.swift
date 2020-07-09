//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

//TODO: When the picker sets a filter set the delegate of the subview to self.

import UIKit
import Photos

class ImagePostViewController: UIViewController {
    // MARK: - Properties -
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var filterPicker: UIPickerView!
    @IBOutlet weak var imageSelectionButton: UIButton!
    
    
    //MARK: - Life Cycles -
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    
    //MARK: - Actions -
    @IBAction func selectImage(_ sender: Any) {
        presentImagePicker()
    }
    
    
    //MARK: - Methods -
    private func setUpViews() {
        selectedImageView.isUserInteractionEnabled = true
        imageSelectionButton.backgroundColor = .none
        controlView.isUserInteractionEnabled = true
        controlView.subviews.forEach { $0.removeFromSuperview() }
        let noFilter = NoFilter()
        setupControl(noFilter)
        filterPicker.delegate = self
        filterPicker.dataSource = self
        filterPicker.isUserInteractionEnabled = true
        updateViews()
    }
    
    private func updateViews() {
        if selectedImageView.image == nil {
            imageSelectionButton.setTitle("Tap to get started.", for: .normal)
        } else {
            imageSelectionButton.setTitle("", for: .normal)
        }
        
    }
    
    private func presentImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("The photo library is not available.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func setupControl(_ control: UIView) {
           control.translatesAutoresizingMaskIntoConstraints = false
           control.contentMode = .scaleAspectFit
           controlView.addSubview(control)
           control.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
           control.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
           control.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
           control.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
       }
    
    private func updateControls(filter: FilterType) {
        controlView.subviews.forEach { $0.removeFromSuperview() }
        switch filter {
        case .noFilter:
            let noFilter = NoFilter()
            setupControl(noFilter)
        case .motionBlur:
            let motionBlur = MotionBlurControl()
            motionBlur.delegate = self
            motionBlur.image = self.selectedImageView.image
            setupControl(motionBlur)
        case .colorMonochrome:
            let colorMonochrome = ColorMonochromeControl()
            colorMonochrome.delegate = self
            colorMonochrome.image = self.selectedImageView.image
            setupControl(colorMonochrome)
        case .circleSplash:
            let circleSplash = CircleSplashControl()
            circleSplash.delegate = self
            circleSplash.image = self.selectedImageView.image
            setupControl(circleSplash)
        case .sharpenLuminance:
            let sharpenLuminance = SharpenLuminanceControl()
            sharpenLuminance.delegate = self
            sharpenLuminance.image = self.selectedImageView.image
            setupControl(sharpenLuminance)
        case .bloom:
            let bloom = BloomControl()
            bloom.delegate = self
            bloom.image = self.selectedImageView.image
            setupControl(bloom)
        }
    }
}



// MARK: - Extensions -
extension ImagePostViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let filter = FilterType.allCases[row]
        updateControls(filter: filter)
    }
    
}


extension ImagePostViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        FilterType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        FilterType.allCases[row].rawValue
    }
}


extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.selectedImageView.image = selectedImage
            updateViews()
        }
        dismiss(animated: true, completion: nil)
        updateViews()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension ImagePostViewController: FilteredImageDelegate {
    func filteredImage(_ image: UIImage) {
        self.selectedImageView.image = image
    }
    
    func saveCurrentImage() {
        guard let imageToSave = selectedImageView.image else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                NSLog("User must grant photo library permissions to access photos.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAsset(from: imageToSave)
            }) { (success, error) in
                if let error = error {
                    NSLog("Something went wrong saving the photo to the device library. \(error) \(error.localizedDescription)")
                    return
                }
            }
        }
    }
}
