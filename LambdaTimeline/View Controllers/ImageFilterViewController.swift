//
//  ImageFilterViewController.swift
//  LambdaTimeline
//
//  Created by Cora Jacobson on 10/29/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum FilterType: String, CaseIterable {
    case none = "No Filter"
    case hueAdjust = "Hue Adjust"
    case colorMonochrome = "Color Monochrome"
    case bumpDistortion = "Bump Distortion"
    case twirlDistortion = "Twirl Distortion"
    case crystallize = "Crystallize"
}

protocol FilterVCDelegate: AnyObject {
    func updateImage(originalImage: UIImage, filteredImage: UIImage?)
}

class ImageFilterViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var pickerView: UIPickerView!
    @IBOutlet private var label1: UILabel!
    @IBOutlet private var slider1: UISlider!
    @IBOutlet private var label2: UILabel!
    @IBOutlet private var slider2: UISlider!
    @IBOutlet private var label3: UILabel!
    @IBOutlet private var slider3: UISlider!
    @IBOutlet private var imageHeightConstraint: NSLayoutConstraint!
    
    var originalImage: UIImage?
    var filteredImage: UIImage?
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    private let filters = FilterType.allCases.map { $0.rawValue }
    private var activeFilter: FilterType = .none
    private var touchPoint: CGPoint?
    private let context = CIContext()
    weak var delegate: FilterVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        setUpView()
    }

    @IBAction func slider1Changed(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func slider2Changed(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func slider3Changed(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func applyFilters(_ sender: UIButton) {
        if let originImage = originalImage {
            self.delegate?.updateImage(originalImage: originImage, filteredImage: filteredImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func setUpView() {
        if let filteredImage = filteredImage {
            imageView.image = filteredImage
            var scaledSize = imageView.bounds.size
            let scale = imageView.contentScaleFactor
            scaledSize.width *= scale
            scaledSize.height *= scale
            
            guard let scaledUIImage = filteredImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }
            scaledImage = CIImage(image: scaledUIImage)
        } else if let originalImage = originalImage {
            imageView.image = originalImage
            var scaledSize = imageView.bounds.size
            let scale = imageView.contentScaleFactor
            scaledSize.width *= scale
            scaledSize.height *= scale
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }
            scaledImage = CIImage(image: scaledUIImage)
        }
        imageView.isUserInteractionEnabled = true
        label1.isHidden = true
        label2.isHidden = true
        label3.isHidden = true
        slider1.isHidden = true
        slider2.isHidden = true
        slider3.isHidden = true
    }
    
    private func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        view.layoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            if imageView.frame.contains(position) {
                let xPosition = position.x - imageView.frame.minX
                let yPosition = imageView.bounds.height - (position.y - imageView.frame.minY)
                touchPoint = CGPoint(x: xPosition, y: yPosition)
                updateImage()
            }
        }
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            switch activeFilter {
            case .hueAdjust:
                imageView.image = hueAdjust(byFiltering: scaledImage)
                filteredImage = imageView.image
            case .colorMonochrome:
                imageView.image = colorMonochrome(byFiltering: scaledImage)
                filteredImage = imageView.image
            case .bumpDistortion:
                imageView.image = bumpDistortion(byFiltering: scaledImage)
                filteredImage = imageView.image
            case .twirlDistortion:
                imageView.image = twirlDistortion(byFiltering: scaledImage)
                filteredImage = imageView.image
            case .crystallize:
                imageView.image = crystallize(byFiltering: scaledImage)
                filteredImage = imageView.image
            default:
                if let filteredImage = filteredImage {
                    imageView.image = filteredImage
                } else {
                    imageView.image = originalImage
                }
            }
        } else {
            imageView.image = nil
            filteredImage = nil
        }
    }
    
    private func noFilterSetUp() {
        slider1.isHidden = true
        slider2.isHidden = true
        slider3.isHidden = true
        activeFilter = .none
        if let filteredImage = filteredImage {
            imageView.image = filteredImage
        } else {
            imageView.image = originalImage
        }
    }
    
    private func hueAdjustSetUp() {
        slider1.isHidden = false
        slider1.maximumValue = (.pi * 2)
        slider1.setValue(.pi, animated: true)
        slider2.isHidden = true
        slider3.isHidden = true
        activeFilter = .hueAdjust
        if let filteredImage = filteredImage {
            imageView.image = filteredImage
        } else {
            imageView.image = originalImage
        }
        updateImage()
    }
    
    private func colorMonochromeSetUp() {
        slider1.isHidden = false
        slider1.maximumValue = 1
        slider1.setValue(0.75, animated: true)
        slider2.isHidden = false
        slider2.maximumValue = 1
        slider2.setValue(0, animated: true)
        slider3.isHidden = false
        slider3.maximumValue = 1
        slider3.setValue(1, animated: true)
        activeFilter = .colorMonochrome
        if let filteredImage = filteredImage {
            imageView.image = filteredImage
        } else {
            imageView.image = originalImage
        }
        updateImage()
    }
    
    private func bumpDistortionSetUp() {
        slider1.isHidden = false
        slider1.maximumValue = 300
        slider1.setValue(150, animated: true)
        slider2.isHidden = false
        slider2.maximumValue = 1
        slider2.setValue(0.5, animated: true)
        slider3.isHidden = true
        activeFilter = .bumpDistortion
        if let filteredImage = filteredImage {
            imageView.image = filteredImage
        } else {
            imageView.image = originalImage
        }
        updateImage()
    }
    
    private func twirlDistortionSetUp() {
        slider1.isHidden = false
        slider1.maximumValue = 200
        slider1.setValue(100, animated: true)
        slider2.isHidden = false
        slider2.maximumValue = (.pi * 2)
        slider2.setValue(.pi, animated: true)
        slider3.isHidden = true
        activeFilter = .twirlDistortion
        if let filteredImage = filteredImage {
            imageView.image = filteredImage
        } else {
            imageView.image = originalImage
        }
        updateImage()
    }
    
    private func crystallizeSetUp() {
        slider1.isHidden = false
        slider1.maximumValue = 20
        slider1.setValue(10, animated: true)
        slider2.isHidden = true
        slider3.isHidden = true
        activeFilter = .crystallize
        if let filteredImage = filteredImage {
            imageView.image = filteredImage
        } else {
            imageView.image = originalImage
        }
        updateImage()
    }
    
    private func hueAdjust(byFiltering inputImage: CIImage) -> UIImage? {
        let hueAdjustFilter = CIFilter.hueAdjust()
        hueAdjustFilter.inputImage = inputImage
        hueAdjustFilter.angle = slider1.value
        guard let outputImage = hueAdjustFilter.outputImage else { return nil }
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        return UIImage(cgImage: renderedCGImage)
    }
    
    private func colorMonochrome(byFiltering inputImage: CIImage) -> UIImage? {
        let colorMonochromeFilter = CIFilter.colorMonochrome()
        colorMonochromeFilter.inputImage = inputImage
        colorMonochromeFilter.color = CIColor(red: CGFloat(slider1.value), green: CGFloat(slider2.value), blue: CGFloat(slider3.value), alpha: 1)
        guard let outputImage = colorMonochromeFilter.outputImage else { return nil }
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        return UIImage(cgImage: renderedCGImage)
    }
    
    private func bumpDistortion(byFiltering inputImage: CIImage) -> UIImage? {
        let bumpDistortionFilter = CIFilter.bumpDistortion()
        bumpDistortionFilter.inputImage = inputImage
        bumpDistortionFilter.radius = slider1.value
        bumpDistortionFilter.scale = slider2.value
        let centerWidth = CGFloat(inputImage.extent.width / 2)
        let centerHeight = CGFloat(inputImage.extent.height / 2)
        let center = CGPoint(x: centerWidth, y: centerHeight)
        bumpDistortionFilter.center = touchPoint ?? center
        guard let outputImage = bumpDistortionFilter.outputImage else { return nil }
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        return UIImage(cgImage: renderedCGImage)
    }
    
    private func twirlDistortion(byFiltering inputImage: CIImage) -> UIImage? {
        let twirlDistortionFilter = CIFilter.twirlDistortion()
        twirlDistortionFilter.inputImage = inputImage
        twirlDistortionFilter.radius = slider1.value
        twirlDistortionFilter.angle = slider2.value
        let centerWidth = CGFloat(inputImage.extent.width / 2)
        let centerHeight = CGFloat(inputImage.extent.height / 2)
        let center = CGPoint(x: centerWidth, y: centerHeight)
        twirlDistortionFilter.center = touchPoint ?? center
        guard let outputImage = twirlDistortionFilter.outputImage else { return nil }
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        return UIImage(cgImage: renderedCGImage)
    }
    
    private func crystallize(byFiltering inputImage: CIImage) -> UIImage? {
        let crystallizeFilter = CIFilter.crystallize()
        crystallizeFilter.inputImage = inputImage
        crystallizeFilter.radius = slider1.value
        guard let outputImage = crystallizeFilter.outputImage else { return nil }
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        return UIImage(cgImage: renderedCGImage)
    }
    
}

extension ImageFilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        filters.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        filters[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 1:
            hueAdjustSetUp()
        case 2:
            colorMonochromeSetUp()
        case 3:
            bumpDistortionSetUp()
        case 4:
            twirlDistortionSetUp()
        case 5:
            crystallizeSetUp()
        default:
            noFilterSetUp()
        }
    }
    
}
