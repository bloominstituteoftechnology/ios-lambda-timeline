//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Tobi Kuyoro on 04/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

enum Filter: String {
    case motionBlur = "CIMotionBlur"
    case process = "CIPhotoEffectProcess"
    case tonal = "CIPhotoEffectTonal"
    case mono = "CIPhotoEffectMono"
    case transfer = "CIPhotoEffectTransfer"
}

class ImagePostViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var changeFilterButton: UIButton!
    @IBOutlet weak var savePhotoButton: UIButton!

    // MARK: - Properties

    var originalImage: UIImage?

    private var filter: CIFilter!
    private var context: CIContext!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        changeFilterButton.layer.cornerRadius = 4
        savePhotoButton.layer.cornerRadius = 4

        context = CIContext(options: nil)
        originalImage = imageView.image
    }

    // MARK: - Action

    func scaleImage(_ image: UIImage) -> UIImage {
        var scaledSize = imageView.bounds.size
        let scale = UIScreen.main.scale

        scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
        guard let scaledImage = image.imageByScaling(toSize: scaledSize) else { return UIImage() }

        return scaledImage
    }

    func applyFilter(action: UIAlertAction) {
        guard let image = originalImage else { return }
        let ciImage = CIImage(image: image)

        switch action.title {
        case "Motion Blur":
            filter = CIFilter(name: "CIMotionBlur")
        case "Process":
            filter = CIFilter(name: "CIPhotoEffectProcess")
        case "Tonal":
            filter = CIFilter(name: "CIPhotoEffectTonal")
        case "Mono":
            filter = CIFilter(name: "CIPhotoEffectMono")
        case "Transfer":
            filter = CIFilter(name: "CIPhotoEffectTransfer")
        default:
            break
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)

        processImage()
    }

    func processImage() {
        let inputKeys = filter.inputKeys

        guard let originalImage = originalImage else { return }

        if inputKeys.contains(kCIInputIntensityKey) { filter.setValue(slider.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { filter.setValue(slider.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { filter.setValue(slider.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { filter.setValue(CIVector(x: originalImage.size.width / 2, y: originalImage.size.height / 2),
                                                                   forKey: kCIInputCenterKey) }

        guard let outputCIImage = filter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage,
                                                      from: outputCIImage.extent) else { return }

        let outputImage = UIImage(cgImage: outputCGImage)
        let scaledImage = scaleImage(outputImage)
        imageView.image = scaledImage
    }

    // MARK: - IBActions

    @IBAction func sliderValueChanged(_ sender: Any) {
        processImage()
    }

    @IBAction func changeFilterTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select a Filter", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Motion Blur", style: .default, handler: applyFilter(action:)))
        alert.addAction(UIAlertAction(title: "Process", style: .default, handler: applyFilter(action:)))
        alert.addAction(UIAlertAction(title: "Tonal", style: .default, handler: applyFilter(action:)))
        alert.addAction(UIAlertAction(title: "Mono", style: .default, handler: applyFilter(action:)))
        alert.addAction(UIAlertAction(title: "Transfer", style: .default, handler: applyFilter(action:)))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    @IBAction func savePhotoTapped(_ sender: Any) {
    }

    @IBAction func chooseAnotherPhotoTapped(_ sender: Any) {
    }
}
