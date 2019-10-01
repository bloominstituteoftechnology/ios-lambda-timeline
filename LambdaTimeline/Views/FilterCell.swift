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
	@IBOutlet weak private var filterBtn: UIButton!
	
	var delegate: FilterCellDelegate?
	private var filter = FilterType.Original
	
	@IBAction func filterTapped(_ sender: Any) {
		delegate?.selectedFilter(filter)
	}
	
	func setupView(with image: UIImage?, applying filter: FilterType) {
		let filteredImage = image?.addFilter(filter: filter) ?? image
		
		imageView.image = filteredImage?.imageByScaling(toSize: imageView.frame.size)
		filterBtn.setTitle(filter.regularText, for: .normal)
		self.filter = filter
	}
}
