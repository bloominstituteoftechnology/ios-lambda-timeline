//
//  AddFilterTableViewCell.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 9/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol AddFilterCellDelegate: AnyObject {
	func addFilterCellWasInvoked(_ cell: AddFilterTableViewCell)
}

class AddFilterTableViewCell: UITableViewCell {
	weak var delegate: AddFilterCellDelegate?

	@IBAction func addFilterButtonPressed(_ sender: UIButton) {
		delegate?.addFilterCellWasInvoked(self)
	}
}
