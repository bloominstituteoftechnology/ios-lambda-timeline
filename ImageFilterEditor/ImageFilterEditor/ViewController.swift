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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let filter = CIFilter(name: "CIZoomBlur")
        print(filter!)
        print(filter!.attributes)
        originalImage = imageView.image
    }

    func memefy(_ image: UIImage) -> UIImage? {
        // MARK: - UIImage -> CGImage -> CIImage and back

        // UIImage -> CGImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // filter image
        let filter = CIFilter.zoomBlur()

        // Set values
        filter.inputImage = ciImage
        filter.center = CGPoint(x: image.size.width/2, y: image.size.height/2)
//        filter.center = CGPoint(x: 100, y: 150)

        // CI -> CG -> UI
        guard let outputCIImage = filter.outputImage else { return nil }

        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size )) else { return nil }

        return UIImage(cgImage: outputCGImage)
    }

    // MARK: - Methods

    private func setUpUI() {
    }

    // MARK: - Actions

    @IBAction func memefyButtonTapped(_ sender: Any) {
        guard let scaledImage = scaledImage else { return }
        imageView.image = memefy(scaledImage)
    }

    // MARK: - Enum
    enum MemeMode {
        case zoom
        case vignette
        case bump
        case blur
        case motionBlur
    }
}

