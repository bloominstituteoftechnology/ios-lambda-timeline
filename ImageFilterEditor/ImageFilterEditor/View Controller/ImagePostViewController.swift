//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Wyatt Harrell on 5/4/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Properties
    let effectNames: [String] = ["Exposure"]
    let effectImages: [UIImage] = [UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!]
    
    var originalImage: UIImage? {
        didSet {
            // resize the scaledImage and set it
            guard let originalImage = originalImage else { return }
            // Height and width
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale  // 1x, 2x, or 3x
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            print("scaled size: \(scaledSize)")
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        presentImagePickerController()
    }
    
    // MARK: - Private Methods
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
    
    private func updateViews() {
        if let scaledImage = scaledImage {
            imageView.image = scaledImage
        } else {
            imageView.image = nil
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImagePostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effectNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCell", for: indexPath) as? EffectCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = 15
        cell.nameLabel.text = effectNames[indexPath.item]
        cell.effectImage.image = effectImages[indexPath.item]
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        nameLabel.text = effectNames[indexPath.row]
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
