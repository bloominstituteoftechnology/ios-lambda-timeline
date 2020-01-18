//
//  LTTextField.swift
//  LambdaTimeline
//
//  Created by John Kouris on 1/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class LTTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        
        textColor = .label
        tintColor = .label
        textAlignment = .center
        font = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontSizeToFitWidth = true
        minimumFontSize = 12
        
        autocorrectionType = .yes
        returnKeyType = .go
        placeholder = "Add your comment here"
    }
    
}
