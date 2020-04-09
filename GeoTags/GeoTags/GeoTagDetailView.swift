//
//  GeoTagDetailView.swift
//  GeoTags
//
//  Created by Chris Gonzales on 4/9/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import MapKit

class GeoTagDetailView: UIView {
    
    var geoTag: Tag?{
        didSet {
            updateSubViews()
        }
    }
    
    private let latitudeLabel = UILabel()
    private let longitudeLabel = UILabel()
    private let timeLabel = UILabel()
    
    private lazy var dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .short
        result.timeStyle = .short
        return result
    }()
    
    private lazy var latLonFormatter: NumberFormatter = {
        let result = NumberFormatter()
        result.numberStyle = .decimal
        result.minimumIntegerDigits = 1
        result.minimumFractionDigits = 2
        result.maximumFractionDigits = 2
        return result
    }()
    
    private func updateSubViews() {
        guard let geoTag = geoTag else { return }
        let lat = latLonFormatter.string(from: NSNumber(value: geoTag.latitude))
        let long = latLonFormatter.string(from: NSNumber(value: geoTag.longitude))
        latitudeLabel.text = "\(lat)"
        longitudeLabel.text = "\(long)"
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        latitudeLabel.setContentHuggingPriority(.defaultLow+1, for: .horizontal)
        
        let placeDateStackView = UIStackView(arrangedSubviews: [timeLabel])
        placeDateStackView.spacing = UIStackView.spacingUseSystem
        let latLonStackView = UIStackView(arrangedSubviews: [latitudeLabel, longitudeLabel])
        latLonStackView.spacing = UIStackView.spacingUseSystem
        let mainStackView = UIStackView(arrangedSubviews: [placeDateStackView, latLonStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = UIStackView.spacingUseSystem
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        mainStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}


