//
//  FilterCell.swift
//  LambdaTimeline
//
//  Created by Jeffrey Santana on 9/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol FilterCellDelegate {
	func selectedFilter(_ filter: FilterType)
}

class FilterCell: UICollectionViewCell {
    
	@IBOutlet weak private var imageView: UIImageView!
	@IBOutlet weak var filterLbl: UILabel!
	@IBOutlet weak private var filterBtn: UIButton!
	
	var delegate: FilterCellDelegate?
	private var filter = FilterType.Original
	
	@IBAction func filterTapped(_ sender: Any) {
		delegate?.selectedFilter(filter)
	}
	
	func setupView(with image: UIImage, from filter: FilterType) {
		
		imageView.image = image.addFilter(filter: filter)
		filterLbl.text = filter.regularText
		filterBtn.setTitle("", for: .normal)
		self.filter = filter
	}
}
