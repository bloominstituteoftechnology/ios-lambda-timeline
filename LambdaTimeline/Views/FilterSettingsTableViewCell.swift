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
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		guard let filter = filter, let filterAttributes = filter.info else { return }
		filterNameLabel.text = filterAttributes.displayName

		for attribute in filterAttributes.attributes {
			let temp = UILabel()
			temp.text = attribute.displayName
			stackView.addArrangedSubview(temp)
		}

	}

}
