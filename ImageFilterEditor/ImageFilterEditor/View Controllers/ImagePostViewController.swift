//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

//TODO: When the picker sets a filter set the delegate of the subview to self.

import UIKit

class ImagePostViewController: UIViewController {
    // MARK: - Properties -
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var filterPicker: UIPickerView!
    
    
    
    //MARK: - Life Cycles -
    override func viewDidLoad() {
        super.viewDidLoad()
        controlView.subviews.forEach { $0.removeFromSuperview() }
        filterPicker.delegate = self
        filterPicker.dataSource = self
        filterPicker.isUserInteractionEnabled = true
        controlView.isUserInteractionEnabled = true
        
        let noFilter = NoFilter()
        noFilter.bounds = controlView.bounds
        controlView.addSubview(noFilter)
    }
    
    
    //MARK: - Methods -
    private func updateControls(filter: FilterType) {
        controlView.subviews.forEach { $0.removeFromSuperview() }
        switch filter {
        case .noFilter:
            let noFilter = NoFilter()
            noFilter.frame.size = controlView.bounds.size
            controlView.addSubview(noFilter)
        case .motionBlur:
            let motionBlur = MotionBlurControl()
            motionBlur.frame.size = controlView.bounds.size
            motionBlur.delegate = self
            motionBlur.image = self.selectedImageView.image
            controlView.addSubview(motionBlur)
        case .colorMonochrome:
            let colorMonochrome = ColorMonochromeControl()
            colorMonochrome.frame.size = controlView.bounds.size
            colorMonochrome.delegate = self
            colorMonochrome.image = self.selectedImageView.image
            controlView.addSubview(colorMonochrome)
        case .circleSplash:
            let circleSplash = CircleSplashControl()
            circleSplash.frame.size = controlView.bounds.size
            circleSplash.delegate = self
            circleSplash.image = self.selectedImageView.image
            controlView.addSubview(circleSplash)
        case .sharpenLuminance:
            let sharpenLuminance = SharpenLuminanceControl()
            sharpenLuminance.frame.size = controlView.bounds.size
            sharpenLuminance.delegate = self
            sharpenLuminance.image = self.selectedImageView.image
            controlView.addSubview(sharpenLuminance)
        case .bloom:
            let bloom = BloomControl()
            bloom.frame.size = controlView.bounds.size
            bloom.delegate = self
            bloom.image = self.selectedImageView.image
            controlView.addSubview(bloom)
        }
    }

}

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

extension ImagePostViewController: FilteredImageDelegate {
    func filteredImage(_ image: UIImage) {
        self.selectedImageView.image = image
    }
}
