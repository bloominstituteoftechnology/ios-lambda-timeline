//
//  UIColorExt.swift
//  LambdaTimeline
//
//  Created by Michael on 3/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b:         CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
        }
    }
    extension Int {
        var degreesToRadians: CGFloat {
            return CGFloat(self) * .pi / 180.0
        }
    }
    extension Double {
        var toTimeString: String {
        let seconds: Int = Int(self.truncatingRemainder(dividingBy: 60.0))
        let minutes: Int = Int(self / 60.0)
        return String(format: "%d:%02d", minutes, seconds)
        }
    }
