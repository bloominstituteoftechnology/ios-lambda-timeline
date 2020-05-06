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

	var filterHolder: FilterHolder? {
		didSet {
			updateViews()
		}
	}

	private func updateViews() {
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		guard let filter = filterHolder?.filter, let filterAttributes = filter.info else { return }
		filterNameLabel.text = filterAttributes.displayName

		for attribute in filterAttributes.attributes {
			let setting = SettingSlider()
			setting.title = attribute.displayName
			setting.maxValue = attribute.sliderMax?.floatValue ?? attribute.maximum?.floatValue ?? 1
			setting.minValue = attribute.sliderMin?.floatValue ?? attribute.minimum?.floatValue ?? 0
			setting.value = filterHolder?.currentValues[attribute]?.floatValue ?? 0.5
			setting.delegate = self
			stackView.addArrangedSubview(setting)
		}
	}
}

extension FilterSettingsTableViewCell: SettingSliderDelegate {
	func settingSlider(_ settingSlider: SettingSlider, changedValue value: Float) {
		guard let filter = filterHolder?.filter, let filterAttributes = filter.info else { return }
		for attribute in filterAttributes.attributes where attribute.displayName == settingSlider.title {
			filterHolder?.currentValues[attribute] = CGFloat(value)
		}
	}
}
