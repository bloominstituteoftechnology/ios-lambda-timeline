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
    @IBOutlet weak var filterContainerView: UIView!
    @IBOutlet var showFilterContainerConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showFilterContainerConstraint.isActive = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateContentSize()
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filterCVC = segue.destination as? FilterCollectionViewController {
            filterCVC.delegate = self
        }
    }

    private func updateContentSize() {
        if showFilterContainerConstraint.isActive {
            preferredContentSize.height = toolbar.frame.height + filterContainerView.frame.height + view.safeAreaInsets.bottom
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

extension SelectFilterViewController: FilterSelectionDelegate {
    func selectedFilter() {
        performSegue(withIdentifier: "ApplyFilterSegue", sender: self)
    }
}
