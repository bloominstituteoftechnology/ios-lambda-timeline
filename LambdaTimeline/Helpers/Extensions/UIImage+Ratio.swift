//
//  UIImage+Ratio.swift
//  LambdaTimeline
//
//  Created by Michael Stoffer on 9/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

extension UIImage {
    var ratio: CGFloat {
        return size.height / size.width
    }
}
