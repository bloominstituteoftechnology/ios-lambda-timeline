//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Jessie Ann Griffin on 5/6/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    @IBOutlet weak var filterTableView: UITableView!
    
    // MARK: - Properties
    let context = CIContext()
    private let whitePointAdjustmentFilter = CIFilter.whitePointAdjust()
    private let crystallizeFilter = CIFilter.crystallize()
    private let noirFilter = CIFilter.photoEffectNoir()
    
    var selectedFilter = 0
    let filterArray = ["Noise Reduction", "Color Control", "White Point Adjustment", "Crystallize", "Photo Filter Noir"]
    var isFiltering: Bool = false

    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale: CGFloat = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width*scale,
                                height: scaledSize.height*scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else { return }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }

    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//      let filter = CIFilter.gaussianBlur()
//      print(filter.attributes)
        filterTableView.dataSource = self
        filterTableView.delegate = self
        originalImage = imageView.image
    }

    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = UIImage(ciImage: scaledImage)
                //image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }

    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func selectPhotoButtonPressed(_ sender: UIBarButtonItem) {
        if selectImageButton.title == "Select Image" {
            presentImagePickerController()
        }
//          else {
//            guard let originalImage = originalImage?.flattened, let ciImage = CIImage(image: originalImage) else { return }
//
//            let processedImage = self.image(byFiltering: ciImage)
//
//            PHPhotoLibrary.requestAuthorization { status in
//                guard status == .authorized else { return }
//
//                PHPhotoLibrary.shared().performChanges({
//                    PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
//                }) { (success, error) in
//                    if let error = error {
//                        print("Error saving photo: \(error)")
//                        // NSLog("%@", error)
//                        return
//                    }
//
//                    DispatchQueue.main.async {
//                        self.presentSuccessfulSaveAlert()
//                    }
//                }
//            }
//        }
    }

    private func presentSuccessfulSaveAlert() {
        let alert = UIAlertController(title: "Photo Saved!", message: "The photo has been saved to your Photo Library!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}


extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagePostViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filterTableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        cell.textLabel?.text = filterArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "PresentNoiseFilter", sender: nil)
        case 1:
            performSegue(withIdentifier: "PresentColorControlFilter", sender: nil)
        case 2:
            performSegue(withIdentifier: "PresentWhitePointFilter", sender: nil)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PresentNoiseFilter":
            guard let destinationVC = segue.destination as? NoiseReductionFilterViewController else { return }
            if let originalImage = originalImage {
                destinationVC.passedImage = originalImage
                destinationVC.context = context
            }
//            destinationVC.imageView.image = UIImage(ciImage: scaledImage!)

        case "PresentColorControlFilter":
            guard let destinationVC = segue.destination as? ColorControlFilterViewController else { return }
            if let originalImage = originalImage {
                destinationVC.passedImage = originalImage
                destinationVC.context = context
            }
//            destinationVC.imageView.image = UIImage(ciImage: scaledImage!)

        case "PresentWhitePointFilter":
            guard let destinationVC = segue.destination as? WhitePointFilterViewController else { return }
            if let scaledImage = scaledImage {
                destinationVC.scaledImage = UIImage(ciImage: scaledImage)
            }
//            destinationVC.imageView.image = UIImage(ciImage: scaledImage!)

        default:
            break
        }
    }
    
}
