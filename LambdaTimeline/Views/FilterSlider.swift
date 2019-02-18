//
//  FilterSlider.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class FilterSlider {
    let attributeName: String
    let displayName: String
    let minimumValue: Float
    let maximumValue: Float
    let defaultValue: Float
    
    lazy var slider: UISlider = {
        let s = UISlider()
        s.minimumValue = minimumValue
        s.maximumValue = maximumValue
        s.value = defaultValue
        return s
    }()
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.text = displayName
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()
    
    lazy var view: UIView = {
        let stack = UIStackView(arrangedSubviews: [label, slider])
        stack.axis = .horizontal
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    
    init?(name: String, attributes: Any) {
        guard let attrs = attributes as? Dictionary<String, Any> else { return nil }
        
        guard let valueClassName = attrs[kCIAttributeClass] as? String else { return nil }
        guard valueClassName == "NSNumber" else { return nil }
        
        guard let minValue = attrs[kCIAttributeSliderMin] as? Float else { return nil }
        guard let maxValue = attrs[kCIAttributeSliderMax] as? Float else { return nil }
        
        let identityValue = attrs[kCIAttributeIdentity] as? Float
        let defaultValue = attrs[kCIAttributeDefault] as? Float
        
        self.attributeName = name
        self.displayName = attrs[kCIAttributeDisplayName] as? String ?? name
        self.minimumValue = minValue
        self.maximumValue = maxValue
        self.defaultValue = defaultValue ?? identityValue ?? minValue
    }
}
