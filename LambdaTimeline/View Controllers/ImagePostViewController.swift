//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {

	// --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
	// MARK: - Outlets
	
	@IBOutlet weak var topSliderLabel: UILabel!
	@IBOutlet weak var middleSliderLabel: UILabel!
	@IBOutlet weak var bottomLabelSlider: UILabel!

	@IBOutlet weak var topSlider: UISlider!
	@IBOutlet weak var middleSlider: UISlider!
	@IBOutlet weak var bottomSlider: UISlider!

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var chooseImageButton: UIButton!
	@IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var postButton: UIBarButtonItem!

	@IBOutlet weak var topSliderStackView: UIStackView!
	@IBOutlet weak var middleSliderStackView: UIStackView!
	@IBOutlet weak var bottomSliderStackView: UIStackView!


	var postController: PostController!
	var post: Post?
	var imageData: Data?

	private var filter = CIFilter(name: "CIColorControls")!
	private var context = CIContext(options: nil)

	var originalImage: UIImage? {
		didSet {

		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		originalImage = imageView.image

        setImageViewHeight(with: 1.0)

        updateViews()
    }

	// --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
	// MARK: Helper Methods
	private func filterImage(_ image: UIImage) -> UIImage {
		guard let cgImage = image.cgImage else { return image }

		let ciImage = CIImage(cgImage: cgImage)

		// Sets up the filter
		filter.setValue(ciImage, forKey: kCIInputImageKey)

		setFilter()

		guard let outputCIImage = filter.outputImage else { return image }

		guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return image }

		return UIImage(cgImage: outputCGImage)
	}

	private func setFilter() {
		switch filter.name {
		case "CIVignette": setVignette()

		default:
			setColorControls()
		}
	}

	private func setColorControls() {

		filter.setValue(topSlider.value, forKey: kCIInputBrightnessKey)
		filter.setValue(middleSlider.value, forKey: kCIInputContrastKey)
		filter.setValue(bottomSlider.value, forKey: kCIInputSaturationKey)
	}

	private func setVignette() {

		filter.setValue(topSlider.value, forKey: kCIInputIntensityKey)
		filter.setValue(middleSlider.value, forKey: kCIInputRadiusKey)
	}


    func updateViews() {

        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }

        title = post?.title

        setImageViewHeight(with: image.ratio)

        imageView.image = image

        chooseImageButton.setTitle("", for: [])
    }

    private func presentImagePickerController() {

        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }

        let imagePicker = UIImagePickerController()

        imagePicker.delegate = self

        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }

	// --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
	// MARK:- - Actions
    @IBAction func createPost(_ sender: Any) {

        view.endEditing(true)

        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }

        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }

            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func chooseImage(_ sender: Any) {

        let authorizationStatus = PHPhotoLibrary.authorizationStatus()

        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:

            PHPhotoLibrary.requestAuthorization { (status) in

                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }

                self.presentImagePickerController()
            }

        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")

        }
		presentImagePickerController()
    }

	// CConfigure Segmented Control

	@IBAction func segmentedControlChange(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0: filter = CIFilter(name: "CIColorControls")!

		default:
			<#code#>
		}

	}

	private func configureColorSegmentSliderValues() {
		UIView.animate(withDuration: 0.3) {
			self.topSliderStackView.isHidden = false
			self.middleSliderStackView.isHidden = false
			self.bottomSliderStackView.isHidden = false

			self.topSlider.value = 0
			self.topSlider.minimumValue = -1
			self.topSlider.maximumValue = 1

			self.middleSlider.setValue(0, animated: true)
			self.middleSlider.minimumValue = 0.25
			self.middleSlider.maximumValue = 4

			self.bottomSlider.value = 0
			self.bottomSlider.minimumValue = 0.25
			self.bottomSlider.maximumValue = 4

		}
	}


	

    func setImageViewHeight(with aspectRatio: CGFloat) {

        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio

        view.layoutSubviews()
    }

}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
