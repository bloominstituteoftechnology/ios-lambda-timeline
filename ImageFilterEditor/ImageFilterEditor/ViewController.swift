//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Karen Rodriguez on 5/4/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    // Segmented Control
    @IBOutlet weak var filterPicker: UISegmentedControl!
    // Labels
    @IBOutlet weak var sliderALabel: UILabel!
    @IBOutlet weak var sliderBLabel: UILabel!
    @IBOutlet weak var sliderCLabel: UILabel!
    @IBOutlet weak var sliderDLabel: UILabel!
    // Sliders
    @IBOutlet weak var sliderA: UISlider!
    @IBOutlet weak var sliderB: UISlider!
    @IBOutlet weak var sliderC: UISlider!
    @IBOutlet weak var sliderD: UISlider!

    // MARK: - Properties
    let context = CIContext(options: nil)

    var originalImage: UIImage? {
        didSet {
            // resize the scaledImage and set it
            guard let originalImage = originalImage else { return }

            // Height and width
            var scaledSize = imageView.bounds.size
            print("This is imageView bounds size size \(scaledSize)")
            let scale = UIScreen.main.scale  // 1x, 2x, or 3x
            print("This is UISCreen main scale \(scale)")

            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            print("scaled size: \(scaledSize)")

            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }

    var scaledImage: UIImage?

    // MARK: - View Controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let filter = CIFilter(name: "CIZoomBlur")
        print(filter!)
        print(filter!.attributes)
        originalImage = imageView.image
        setUpUI()
    }

    func zoomBlur(_ image: UIImage) -> UIImage? {
        // MARK: - UIImage -> CGImage -> CIImage and back

        // UIImage -> CGImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // filter image
        let filter = CIFilter.zoomBlur()

        // Set values
        filter.inputImage = ciImage
        filter.center = CGPoint(x: CGFloat(sliderA.value), y: CGFloat(sliderB.value))
        filter.amount = sliderC.value
        //        filter.center = CGPoint(x: 100, y: 150)

        // CI -> CG -> UI
        guard let outputCIImage = filter.outputImage else { return nil }

        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size )) else { return nil }

        return UIImage(cgImage: outputCGImage)
    }

    func vignette(_ image: UIImage) -> UIImage? {
        // MARK: - UIImage -> CGImage -> CIImage and back

        // UIImage -> CGImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // filter image
        let filter = CIFilter.vignetteEffect()

        // Set values
        filter.inputImage = ciImage
        filter.center = CGPoint(x: CGFloat(sliderA.value), y: CGFloat(sliderB.value))
        filter.intensity = sliderC.value
        filter.radius = sliderD.value
        //        filter.center = CGPoint(x: 100, y: 150)

        // CI -> CG -> UI
        guard let outputCIImage = filter.outputImage else { return nil }

        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size )) else { return nil }

        return UIImage(cgImage: outputCGImage)
    }

    func bumpDistort(_ image: UIImage) -> UIImage? {
        // MARK: - UIImage -> CGImage -> CIImage and back

        // UIImage -> CGImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // filter image
        let filter = CIFilter(name: "CIBumpDistortion")!

        // Set values
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let centerVector = CIVector(cgPoint: CGPoint(x: CGFloat(sliderA.value), y: CGFloat(sliderB.value)))
        filter.setValue(centerVector, forKey: kCIInputCenterKey)
        //        filter.center = CGPoint(x: 100, y: 150)
        filter.setValue(sliderC.value, forKey: kCIInputRadiusKey)
        filter.setValue(sliderD.value, forKey: kCIInputScaleKey)

        // CI -> CG -> UI
        guard let outputCIImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
//        guard let outputCIImage = filter.outputImage else { return nil }

        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size )) else { return nil }

        return UIImage(cgImage: outputCGImage)
    }

    func gaussian(_ image: UIImage) -> UIImage? {
        // MARK: - UIImage -> CGImage -> CIImage and back

        // UIImage -> CGImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // filter image
        let filter = CIFilter.gaussianBlur()

        // Set values
        filter.inputImage = ciImage
        filter.radius = sliderA.value
        //        filter.center = CGPoint(x: 100, y: 150)

        // CI -> CG -> UI
        guard let outputCIImage = filter.outputImage else { return nil }

        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size )) else { return nil }

        return UIImage(cgImage: outputCGImage)
    }

    func motion(_ image: UIImage) -> UIImage? {
        // MARK: - UIImage -> CGImage -> CIImage and back

        // UIImage -> CGImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // filter image
        let filter = CIFilter.motionBlur()

        // Set values
        filter.inputImage = ciImage
        filter.radius = sliderA.value
        filter.angle = sliderB.value
        //        filter.center = CGPoint(x: 100, y: 150)

        // CI -> CG -> UI
        guard let outputCIImage = filter.outputImage else { return nil }

        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size )) else { return nil }

        return UIImage(cgImage: outputCGImage)
    }

    // MARK: - Methods

    private func setUpUI() {
        let allLabels = [sliderALabel, sliderBLabel, sliderCLabel, sliderDLabel]
        let allSliders = [sliderA, sliderB, sliderC, sliderD]

        for label in allLabels {
            label?.isHidden = true
        }

        for slider in allSliders {
            slider?.isHidden = true
        }
        switch filterPicker.selectedSegmentIndex {
        case 0:
            for i in 0..<allLabels.count - 1 {
                allLabels[i]?.isHidden = false
                allSliders[i]?.isHidden = false
            }
            sliderALabel.text = "Blur Center X:"
            sliderBLabel.text = "Blur Center Y:"
            sliderCLabel.text = "Blur Amount:"

            sliderA.minimumValue = 0
            sliderA.maximumValue = Float((scaledImage?.size.width)!)
            sliderA.value = Float((scaledImage?.size.width)!) / 2

            sliderB.minimumValue = 0
            sliderB.maximumValue = Float((scaledImage?.size.height)!)
            sliderB.value = Float((scaledImage?.size.height)!) / 2

            sliderC.minimumValue = 0
            sliderC.maximumValue = 100
            sliderC.value = 20


        case 1:
            for i in 0..<allLabels.count {
                allLabels[i]?.isHidden = false
                allSliders[i]?.isHidden = false
            }
            sliderALabel.text = "Vignette Center X:"
            sliderBLabel.text = "Vignette Center Y:"
            sliderCLabel.text = "Intensity:"
            sliderDLabel.text = "Radius:"

            sliderA.minimumValue = 0
            sliderA.maximumValue = Float((scaledImage?.size.width)!)
            sliderA.value = Float((scaledImage?.size.width)!) / 2

            sliderB.minimumValue = 0
            sliderB.maximumValue = Float((scaledImage?.size.height)!)
            sliderB.value = Float((scaledImage?.size.height)!) / 2

            sliderC.minimumValue = 0
            sliderC.maximumValue = 1
            sliderC.value = 0.3

            sliderD.minimumValue = 0
            sliderD.maximumValue = 2000
            sliderD.value = 100
        case 2:
            for i in 0..<allLabels.count {
                allLabels[i]?.isHidden = false
                allSliders[i]?.isHidden = false
            }
            sliderALabel.text = "Bump Center X:"
            sliderBLabel.text = "Bump Center Y:"
            sliderCLabel.text = "Radius:"
            sliderDLabel.text = "Scale:"

            sliderA.minimumValue = 0
            sliderA.maximumValue = Float((scaledImage?.size.width)!)
            sliderA.value = Float((scaledImage?.size.width)!) / 2

            sliderB.minimumValue = 0
            sliderB.maximumValue = Float((scaledImage?.size.height)!)
            sliderB.value = Float((scaledImage?.size.height)!) / 2

            sliderC.minimumValue = 0
            sliderC.maximumValue = 2000
            sliderC.value = 300

            sliderD.minimumValue = 0
            sliderD.maximumValue = 1
            sliderD.value = 0.5
        case 3:
            allLabels[0]?.isHidden = false
            allSliders[0]?.isHidden = false

            sliderALabel.text = "Blur Radius:"
            sliderA.minimumValue = 0
            sliderA.maximumValue = 100
            sliderA.value = 10
        case 4:
            allLabels[0]?.isHidden = false
            allSliders[0]?.isHidden = false
            allLabels[1]?.isHidden = false
            allSliders[1]?.isHidden = false

            sliderALabel.text = "Blur Radius:"
            sliderBLabel.text = "Blur Angle:"

            sliderA.minimumValue = 0
            sliderA.maximumValue = 100
            sliderA.value = 20

            sliderB.minimumValue = 0
            sliderB.maximumValue = 10
            sliderB.value = 0

        default:
            break
        }
    }

    // MARK: - Actions

    @IBAction func filterButtonTapped(_ sender: Any) {
        guard let scaledImage = scaledImage else {
            imageView.image = nil
            return
        }
        switch filterPicker.selectedSegmentIndex {
        case 0:
            imageView.image = zoomBlur(scaledImage)
        case 1:
            imageView.image = vignette(scaledImage)
        case 2:
            imageView.image = bumpDistort(scaledImage)
        case 3:
            imageView.image = gaussian(scaledImage)
        case 4:
            imageView.image = motion(scaledImage)
        default:
            break
        }
    }

    @IBAction func segmentSectionTapped(_ sender: UISegmentedControl) {
        imageView.image = scaledImage
        setUpUI()
    }
}

// MARK: - Extensions

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func presentImagePickerController() {

        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self

        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
