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
        controlView.subviews.forEach { $0.removeFromSuperview() }
        filterPicker.delegate = self
        filterPicker.dataSource = self
        filterPicker.isUserInteractionEnabled = true
        controlView.isUserInteractionEnabled = true
        selectedImageView.isUserInteractionEnabled = true
        imageSelectionButton.backgroundColor = .none
        
        if selectedImageView.image == nil {
            imageSelectionButton.setTitle("Tap to get started.", for: .normal)
        } else {
            imageSelectionButton.setTitle("", for: .normal)
        }
        
        let noFilter = NoFilter()
//        noFilter.translatesAutoresizingMaskIntoConstraints = false
//        noFilter.contentMode = .scaleAspectFit
//        controlView.addSubview(noFilter)
//        noFilter.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
//        noFilter.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
//        noFilter.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
//        noFilter.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        setupControl(noFilter)
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
    
    private func updateControls(filter: FilterType) {
        controlView.subviews.forEach { $0.removeFromSuperview() }
        switch filter {
        case .noFilter:
            let noFilter = NoFilter()
//            noFilter.translatesAutoresizingMaskIntoConstraints = false
//            noFilter.contentMode = .scaleAspectFit
//            controlView.addSubview(noFilter)
//            noFilter.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
//            noFilter.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
//            noFilter.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
//            noFilter.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
            setupControl(noFilter)
        case .motionBlur:
            let motionBlur = MotionBlurControl()
           // motionBlur.translatesAutoresizingMaskIntoConstraints = false
            motionBlur.delegate = self
            motionBlur.image = self.selectedImageView.image
            setupControl(motionBlur)
//            motionBlur.contentMode = .scaleAspectFit
//            controlView.addSubview(motionBlur)
//            motionBlur.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
//            motionBlur.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
//            motionBlur.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
//            motionBlur.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .colorMonochrome:
            let colorMonochrome = ColorMonochromeControl()
        //    colorMonochrome.translatesAutoresizingMaskIntoConstraints = false
            colorMonochrome.delegate = self
            colorMonochrome.image = self.selectedImageView.image
            setupControl(colorMonochrome)
//            colorMonochrome.contentMode = .scaleAspectFit
//            controlView.addSubview(colorMonochrome)
//            colorMonochrome.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
//            colorMonochrome.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
//            colorMonochrome.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
//            colorMonochrome.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .circleSplash:
            let circleSplash = CircleSplashControl()
           // circleSplash.translatesAutoresizingMaskIntoConstraints = false
            circleSplash.delegate = self
            circleSplash.image = self.selectedImageView.image
            setupControl(circleSplash)
//            circleSplash.contentMode = .scaleAspectFit
//            controlView.addSubview(circleSplash)
//            circleSplash.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
//            circleSplash.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
//            circleSplash.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
//            circleSplash.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .sharpenLuminance:
            let sharpenLuminance = SharpenLuminanceControl()
//            sharpenLuminance.translatesAutoresizingMaskIntoConstraints = false
            sharpenLuminance.delegate = self
            sharpenLuminance.image = self.selectedImageView.image
            setupControl(sharpenLuminance)
//            sharpenLuminance.contentMode = .scaleAspectFit
//            controlView.addSubview(sharpenLuminance)
//            sharpenLuminance.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
//            sharpenLuminance.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
//            sharpenLuminance.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
//            sharpenLuminance.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .bloom:
            let bloom = BloomControl()
            //bloom.translatesAutoresizingMaskIntoConstraints = false
            bloom.delegate = self
            bloom.image = self.selectedImageView.image
            setupControl(bloom)
//            bloom.contentMode = .scaleAspectFit
//            controlView.addSubview(bloom)
//            bloom.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
//            bloom.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
//            bloom.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
//            bloom.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        }
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
