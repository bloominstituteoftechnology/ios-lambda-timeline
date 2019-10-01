//
//  FilterSettingsTableViewCell.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 9/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class FilterSettingsTableViewCell: UITableViewCell {
	@IBOutlet private var stackView: UIStackView!
	@IBOutlet private var filterNameLabel: UILabel!

	var filter: CIFilter? {
		didSet {
			updateViews()
		}
	}

	private func updateViews() {
		guard let filter = filter else { return }
		for att in filter.attributes {
			att
		}
	}

}
