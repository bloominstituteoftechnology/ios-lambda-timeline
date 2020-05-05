//
//  SelectFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/4/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class SelectFilterViewController: UIViewController {

    var animationDuration = 0.3
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet var showFilterContainerConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showFilterContainerConstraint.isActive = false
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateContentSize()
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    private func updateContentSize() {
        if showFilterContainerConstraint.isActive {
            preferredContentSize.height = toolbar.frame.height + filterCollectionView.frame.height + view.safeAreaInsets.bottom
        } else {
            preferredContentSize.height = toolbar.frame.height + view.safeAreaInsets.bottom
        }
    }

    @IBAction func showFilters(_ sender: Any) {
        showFilterContainerConstraint.isActive.toggle()
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        updateContentSize()
    }
}

// MARK: UICollectionViewDataSource

extension SelectFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath)
    
        // Configure the cell
    
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension SelectFilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ApplyFilterSegue", sender: self)
    }
}

   

   

   
   
   
