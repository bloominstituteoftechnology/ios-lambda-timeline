//
//  UIView+Gradient.swift
//  Lambda Timeline
//
//  Created by Dillon McElhinney on 1/3/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

extension UIView {
    func addGradient(startColor: UIColor, endColor: UIColor) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
//        gradient.locations = [0.0, 1.0]
//        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = self.layer.frame
        
        self.layer.addSublayer(gradient)
        self.layer.backgroundColor = endColor.cgColor
    }
}
