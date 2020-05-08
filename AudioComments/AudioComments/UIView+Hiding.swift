//
//  UIView+Hiding.swift
//  AudioComments
//
//  Created by Shawn Gee on 5/8/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

extension UIView {
    static func hide(_ views: UIView...) {
        for view in views {
            view.isHidden = true
        }
    }
    
    static func show(_ views: UIView...) {
        for view in views {
            view.isHidden = false
        }
    }
}
