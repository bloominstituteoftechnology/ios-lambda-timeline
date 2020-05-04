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

    var scaledImage: UIImage? {
        didSet {
            if let img = scaledImage {
                imageView.image = img
            }
        }
    }

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
        filter.center = CGPoint(x: 100, y: 150)

        // CI -> CG -> UI
        guard let outputCIImage = filter.outputImage else { return nil }


        return nil
    }

    // MARK: - Methods


    // MARK: - Actions

    @IBAction func memefyButtonTapped(_ sender: Any) {
        guard let scaledImage = scaledImage else { return }
        memefy(scaledImage)
    }

}

