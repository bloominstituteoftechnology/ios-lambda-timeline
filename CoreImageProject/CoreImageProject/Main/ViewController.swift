//
//  ViewController.swift
//  CoreImageProject
//
//  Created by Kenny on 6/1/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ViewController: UIViewController {
    // MARK: - Outlets -
    //Image View
    @IBOutlet private var imageView: UIImageView!
    //Stack Views
    @IBOutlet weak var colorStack: UIStackView!
    @IBOutlet weak var colorStack2: UIStackView!
    @IBOutlet weak var sliderStack1: UIStackView!
    @IBOutlet weak var sliderStack2: UIStackView!
    @IBOutlet weak var sliderStack3: UIStackView!
    

    //Slider Labels
    @IBOutlet weak var slider1Label: UILabel!
    @IBOutlet weak var slider2Label: UILabel!
    @IBOutlet weak var slider3Label: UILabel!
    //Sliders
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!


    // MARK: - Properties -
    private var originalImage: UIImage?
    ///set the filter's inputImage
    private var inputImage: CIImage? {
        guard let originalImage = originalImage,
            let cgImage = originalImage.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
        return ciImage
    }
    private let context = CIContext(options: nil)
    private var filter: CIFilter = .gaussianBlur() {
        didSet {
            updateViews()
        }
    }
    //Colors for Checkerboard
    var color1: CIColor = CIColor(color: UIColor.black)
    var color2: CIColor = CIColor(color: UIColor.white)

    // MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = UIImage(named: "ball")!
        imageView.image = originalImage
        setupGaussianUI()
        setupGaussianFilter()
    }

    private func updateViews() {
        switch filter.name {
        case "CIGaussianBlur":
            setupGaussianFilter()
        case "CICheckerboardGenerator":
            setupCheckerboardFilter()
        case "CIColorControls":
            setupColorControlsFilter()
        case "CISepiaTone":
            setupSepiaFilter()
        case "CIBloom"
            setupBloomFilter()
        default:
            break
        }
    }

    @IBAction func filterControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filter = .gaussianBlur()
            setupGaussianUI()
        case 1:
            filter = .checkerboardGenerator()
            setupCheckerboardUI()
        case 2:
            filter = .colorControls()
            setupColorControlsUI()
        case 3:
            filter = .sepiaTone()
            setupSepiaUI()
        case 4:
            filter = .bloom()
            setupBloomUI()
        default:
            break
        }
    }

    // MARK: - Filter Implementations -

    //Guassian Blur
    private func setupGaussianUI() {
        imageView.image = originalImage
        colorStack.isHidden = true
        colorStack2.isHidden = true
        slider1Label.text = "Radius"
        slider1.isHidden = false
        slider1.value = 1
        slider1.minimumValue = 0
        slider1.maximumValue = 10
        sliderStack2.isHidden = true
        sliderStack3.isHidden = true
    }

    private func setupGaussianFilter() {
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputRadiusKey)
        if let outputImage = filter.outputImage {
            let filteredImage = UIImage(ciImage: outputImage)
            imageView.image = filteredImage
        }
    }

    //Checkerboard Generator
    private func setupCheckerboardUI() {
        colorStack.isHidden = false
        colorStack2.isHidden = false

        slider1Label.text = "Square Width"
        sliderStack1.isHidden = false
        slider1.value = 80
        slider1.minimumValue = 0
        slider1.maximumValue = 160

        slider2Label.text = "Sharpness"
        sliderStack2.isHidden = false
        slider2.value = 1
        slider2.minimumValue = 0
        slider2.maximumValue = 1

        sliderStack3.isHidden = true
        setupCheckerboardFilter()
    }

    private func setupCheckerboardFilter() {
        let color1Key = "inputColor0"
        let color2Key = "inputColor1"
        filter.setValue(color1, forKey: color1Key)
        filter.setValue(color2, forKey: color2Key)
        filter.setValue(slider1.value, forKey: kCIInputWidthKey)
        filter.setValue(slider2.value, forKey: kCIInputSharpnessKey)
        filter.setValue((CIVector(cgPoint: (imageView.center))), forKey: kCIInputCenterKey)

        if let outputImage = filter.outputImage,
            let image = originalImage,
            let filteredImage = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: image.size)) {
            imageView.image = UIImage(cgImage: filteredImage)
        }
    }

    //Color Controls
    private func setupColorControlsUI() {
        imageView.image = originalImage
        colorStack.isHidden = true
        colorStack2.isHidden = true

        slider1Label.text = "Brightness"
        sliderStack1.isHidden = false
        slider1.value = 0
        slider1.minimumValue = -1
        slider1.maximumValue = 1

        slider2Label.text = "Contrast"
        sliderStack2.isHidden = false
        slider2.value = 1
        slider2.minimumValue = 0
        slider2.maximumValue = 1

        slider3Label.text = "Saturation"
        sliderStack3.isHidden = false
        slider3.value = 1
        slider3.minimumValue = 0
        slider3.maximumValue = 1
    }

    private func setupColorControlsFilter() {
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputBrightnessKey)
        filter.setValue(slider2.value, forKey: kCIInputContrastKey)
        filter.setValue(slider3.value, forKey: kCIInputSaturationKey)
        if let outputImage = filter.outputImage {
            let filteredImage = UIImage(ciImage: outputImage)
            imageView.image = filteredImage
        }
    }

    //Sepia
    private func setupSepiaUI() {
        imageView.image = originalImage
        colorStack.isHidden = true
        colorStack2.isHidden = true

        sliderStack1.isHidden = false
        slider1Label.text = "Intensity"
        slider1.value = 5
        slider1.minimumValue = 0
        slider1.maximumValue = 2

        sliderStack2.isHidden = true
        sliderStack3.isHidden = true
    }

    private func setupSepiaFilter() {
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputIntensityKey)
        if let outputImage = filter.outputImage {
           let filteredImage = UIImage(ciImage: outputImage)
           imageView.image = filteredImage
        }
    }

    //Bloom
    private func setupBloomUI() {
        imageView.image = originalImage
        colorStack.isHidden = true
        colorStack2.isHidden = true

        sliderStack1.isHidden = false
        slider1Label.text = "Intensity"
        slider1.value = 0.5
        slider1.minimumValue = 0
        slider1.maximumValue = 1

        sliderStack2.isHidden = false
        slider2Label.text = "Radius"
        slider2.value = 5
        slider2.minimumValue = 0
        slider2.maximumValue = 10
    }

    private func setupBloomFilter() {
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(slider1.value, forKey: kCIInputIntensityKey)
        filter.setValue(slider2.value, forKey: kCIInputRadiusKey)
        if let outputImage = filter.outputImage {
            let filteredImage = UIImage(ciImage: outputImage)
            imageView.image = filteredImage
        }
    }

    // MARK: - Actions -
    @IBAction func color1WasTapped(_ sender: UIButton) {
        color1 = CIColor(color: sender.backgroundColor ?? .black)
        updateViews()
    }

    @IBAction func color2WasTapped(_ sender: UIButton) {
        color2 = CIColor(color: sender.backgroundColor ?? .white)
        updateViews()
    }

    @IBAction func filterSlider1DidChange(_ sender: UISlider) {
        updateViews()
    }

    @IBAction func filterSlider2DidChange(_ sender: UISlider) {
        updateViews()
    }

    @IBAction func filterSlider3DidChange(_ sender: UISlider) {
        updateViews()
    }
    
}
