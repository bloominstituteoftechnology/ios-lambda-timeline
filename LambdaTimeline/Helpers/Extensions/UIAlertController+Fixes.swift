//
//  UIAlertController+Fixes.swift
//  LambdaTimeline
//
//  Created by Isaac Lyons on 12/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

extension UIAlertController {
    // The following is to fix a bug with action sheet alerts
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
