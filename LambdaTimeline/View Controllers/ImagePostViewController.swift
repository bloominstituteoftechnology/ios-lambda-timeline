//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage

class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setImageViewHeight(with: 1.0)
		filterCollectionView.dataSource = self
		filterCollectionView.delegate = self
		filterCollectionView.isHidden = true
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
//        setImageViewHeight(with: image.ratio)
        
        originalImage = image
        
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
    
//    func setImageViewHeight(with aspectRatio: CGFloat) {
//
//        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
//
//        view.layoutSubviews()
//    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var postButton: UIBarButtonItem!
	
	// MARK: - JEFF Code
	
	// MARK: IBOutlets
	
	@IBOutlet weak var filterCollectionView: UICollectionView!
	
	// MARK: Properties
	
	private var originalImage: UIImage? {
		didSet {
			imageView.image = originalImage
			filterController = FilterController(image: originalImage)
		}
	}
	var filterController: FilterController? {
		didSet {
			displayFilters()
		}
	}
	
	// MARK: IBActions
	
	
	// MARK: Helpers
	
	private func displayFilters() {
		filterController?.createFilters {
			DispatchQueue.main.async {
				self.filterCollectionView.reloadData()
				self.filterCollectionView.isHidden = false
			}
		}
	}
}

// MARK: UIImage Extension

extension UIImage {
	func addFilter(filter: FilterType) -> UIImage? {
		let filter = CIFilter(name: filter.rawValue)
		let ciInput = CIImage(image: self)
		let ciContext = CIContext()
		
		filter?.setValue(ciInput, forKey: kCIInputImageKey)
		
		guard let ciOutput = filter?.outputImage,
			let cgImage = ciContext.createCGImage(ciOutput, from: (ciOutput.extent)) else { return nil }
		
		return UIImage(cgImage: cgImage)
	}
}

// MARK: CollectionView DataSource & Delegate

extension ImagePostViewController: UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		filterController?.filters.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell,
			let filter = filterController?.getFilter(at: indexPath.item) else { return UICollectionViewCell() }
		
		cell.delegate = self
		cell.setupView(with: filter.image, from: filter.type)
		
		return cell
	}

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cellHeight = filterCollectionView.bounds.height * 0.7
         
         return CGSize(width: cellHeight, height: cellHeight)
     }
}

// MARK: FilterCell Delegate

extension ImagePostViewController: FilterCellDelegate {
	func selectedFilter(_ filter: FilterType) {
		imageView.image = originalImage?.addFilter(filter: filter) ?? originalImage
	}
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        originalImage = image
        
//        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
