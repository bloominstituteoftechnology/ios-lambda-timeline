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
    
    // MARK: - Properties
    let effectNames: [String] = ["Depth", "Mono", "Vignette", "Exposure", "Color"]
    let effectImages: [UIImage] = [UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!, UIImage(systemName: "square.and.arrow.up")!]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
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
        return 5
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
}
