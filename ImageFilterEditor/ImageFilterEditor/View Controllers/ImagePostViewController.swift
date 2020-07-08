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
        setUpViews()

    }
    
    
    //MARK: - Methods -
    private func setUpViews() {
        controlView.subviews.forEach { $0.removeFromSuperview() }
        filterPicker.delegate = self
        filterPicker.dataSource = self
        filterPicker.isUserInteractionEnabled = true
        controlView.isUserInteractionEnabled = true
        selectedImageView.isUserInteractionEnabled = true
        
        let noFilter = NoFilter()
        //noFilter.bounds = controlView.bounds
        noFilter.translatesAutoresizingMaskIntoConstraints = false
        noFilter.contentMode = .scaleAspectFit
        controlView.addSubview(noFilter)
        noFilter.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
        noFilter.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
        noFilter.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
        noFilter.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
    }
    
    private func updateControls(filter: FilterType) {
        controlView.subviews.forEach { $0.removeFromSuperview() }
        switch filter {
        case .noFilter:
            let noFilter = NoFilter()
            //noFilter.frame.size = controlView.bounds.size
            noFilter.translatesAutoresizingMaskIntoConstraints = false
            noFilter.contentMode = .scaleAspectFit
            controlView.addSubview(noFilter)
            noFilter.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
            noFilter.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
            noFilter.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
            noFilter.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .motionBlur:
            let motionBlur = MotionBlurControl()
            //motionBlur.frame.size = controlView.bounds.size
            motionBlur.translatesAutoresizingMaskIntoConstraints = false
            motionBlur.delegate = self
            motionBlur.image = self.selectedImageView.image
            motionBlur.contentMode = .scaleAspectFit
            controlView.addSubview(motionBlur)
            motionBlur.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
            motionBlur.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
            motionBlur.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
            motionBlur.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .colorMonochrome:
            let colorMonochrome = ColorMonochromeControl()
            //colorMonochrome.frame.size = controlView.bounds.size
            colorMonochrome.translatesAutoresizingMaskIntoConstraints = false
            colorMonochrome.delegate = self
            colorMonochrome.image = self.selectedImageView.image
            colorMonochrome.contentMode = .scaleAspectFit
            controlView.addSubview(colorMonochrome)
            colorMonochrome.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
            colorMonochrome.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
            colorMonochrome.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
            colorMonochrome.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .circleSplash:
            let circleSplash = CircleSplashControl()
            //circleSplash.frame.size = controlView.bounds.size
            circleSplash.translatesAutoresizingMaskIntoConstraints = false
            circleSplash.delegate = self
            circleSplash.image = self.selectedImageView.image
            circleSplash.contentMode = .scaleAspectFit
            controlView.addSubview(circleSplash)
            circleSplash.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
            circleSplash.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
            circleSplash.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
            circleSplash.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .sharpenLuminance:
            let sharpenLuminance = SharpenLuminanceControl()
            //sharpenLuminance.frame.size = controlView.bounds.size
            sharpenLuminance.translatesAutoresizingMaskIntoConstraints = false
            sharpenLuminance.delegate = self
            sharpenLuminance.image = self.selectedImageView.image
            sharpenLuminance.contentMode = .scaleAspectFit
            controlView.addSubview(sharpenLuminance)
            sharpenLuminance.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
            sharpenLuminance.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
            sharpenLuminance.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
            sharpenLuminance.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
        case .bloom:
            let bloom = BloomControl()
            //bloom.frame.size = controlView.bounds.size
            bloom.translatesAutoresizingMaskIntoConstraints = false
            bloom.delegate = self
            bloom.image = self.selectedImageView.image
            bloom.contentMode = .scaleAspectFit
            controlView.addSubview(bloom)
            bloom.topAnchor.constraint(equalTo: controlView.topAnchor).isActive = true
            bloom.bottomAnchor.constraint(equalTo: controlView.bottomAnchor).isActive = true
            bloom.leadingAnchor.constraint(equalTo: controlView.leadingAnchor).isActive = true
            bloom.trailingAnchor.constraint(equalTo: controlView.trailingAnchor).isActive = true
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
