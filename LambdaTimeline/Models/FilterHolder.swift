//
//  Filter.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 9/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreImage

protocol FilterHolderDelegate: AnyObject {
	func filterHolderFilterHasChanged(_ filterHolder: FilterHolder)
}

class FilterHolder {
	let filter: CIFilter
	var currentValues: [FilterAttributes.FilterAttribute: CGFloat] = [:] {
		didSet {
			delegate?.filterHolderFilterHasChanged(self)
		}
	}

	weak var delegate: FilterHolderDelegate?

	init(filter: CIFilter) {
		self.filter = filter
		guard let info = filter.info else { return }
		self.currentValues = info.attributes.reduce(into: [:]) {
			$0[$1] = $1.default
		}
	}
}
