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

	var postController: PostController!
	var post: Post?
	var imageData: Data?

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var chooseImageButton: UIButton!
	@IBOutlet weak var postButton: UIBarButtonItem!
	@IBOutlet var filterTableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		updateViews()
		filterTableView.tableFooterView = UIView()
	}

	var filterHolders = [FilterHolder]()
	
	func updateViews() {
		guard let imageData = imageData, let image = UIImage(data: imageData) else {
				title = "New Post"
				return
		}
		title = post?.title
		
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
		@unknown default:
			self.presentInformationalAlertController(title: "Error", message: "Unknown status ocurred. Notify the pope.")
		}
		presentImagePickerController()
	}
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		chooseImageButton.setTitle("", for: [])
		picker.dismiss(animated: true, completion: nil)
		
		guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
		imageView.image = image
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

extension ImagePostViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return filterHolders.count
		default:
			return 1
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell: UITableViewCell

		switch indexPath.section {
		case 0:
			cell = getFilterCell(fromTableView: tableView, at: indexPath)
		default:
			cell = getNewFilterButtonCell(fromTableView: tableView, atIndex: indexPath)
		}
		return cell
	}

	func getNewFilterButtonCell(fromTableView tableView: UITableView, atIndex: IndexPath) -> AddFilterTableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: atIndex) as? AddFilterTableViewCell else { fatalError("CELL NO EXIST") }
		cell.delegate = self
		return cell
	}

	func getFilterCell(fromTableView tableView: UITableView, at indexPath: IndexPath) -> FilterSettingsTableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterSettingsTableViewCell else { fatalError("CELL NO EXIST") }
		cell.filterHolder = filterHolders[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			filterHolders.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
}

// MARK: - Filter Stuff
extension ImagePostViewController: AddFilterCellDelegate {
	func addFilterCellWasInvoked(_ cell: AddFilterTableViewCell) {
		let alertVC = UIAlertController(title: "New Filter", message: "What filter would you like to add?", preferredStyle: .actionSheet)
		alertVC.addAction(UIAlertAction(title: "Motion Blur", style: .default, handler: { _ in
			self.addFilter(named: "CIMotionBlur")
		}))
		alertVC.addAction(UIAlertAction(title: "Vignette", style: .default, handler: { _ in
			self.addFilter(named: "CIVignette")
		}))
		alertVC.addAction(UIAlertAction(title: "Sharpen", style: .default, handler: { _ in
			self.addFilter(named: "CIUnsharpMask")
		}))
		alertVC.addAction(UIAlertAction(title: "Vibrance", style: .default, handler: { _ in
			self.addFilter(named: "CIVibrance")
		}))
		alertVC.addAction(UIAlertAction(title: "Exposure", style: .default, handler: { _ in
			self.addFilter(named: "CIExposureAdjust")
		}))
		alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alertVC, animated: true)
	}

	func addFilter(named name: String) {
		filterHolders.append(FilterHolder(filter: CIFilter(name: name)!))
		filterTableView.reloadData()
	}
}
