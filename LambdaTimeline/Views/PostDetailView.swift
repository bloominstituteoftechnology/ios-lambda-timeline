//
//  PostDetailView.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class QuakeDetailView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        latitudeLabel.setContentHuggingPriority(.defaultLow+1, for: .horizontal)
        
        let placeDateStackView = UIStackView(arrangedSubviews: [authorLabel, dateLabel])
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
    
    // MARK: - Private
    
    private func updateSubviews() {
        guard let post = post,
            let firstPostComment = post.comments.first,
            let geotag = post.geotag else { return }
        
        let postTimestamp = firstPostComment.timestamp
        let postAuthor = post.author
        authorLabel.text = postAuthor.displayName
        dateLabel.text = dateFormatter.string(from: postTimestamp)
        latitudeLabel.text = "Lat: " + latLonFormatter.string(from: geotag.latitude as NSNumber)!
        longitudeLabel.text = "Long: " + latLonFormatter.string(from: geotag.longitude as NSNumber)!
        
        let popularity = post.comments.count
        
        switch popularity {
            case 0..<2:
                authorLabel.backgroundColor = .green
            case 2..<5:
                authorLabel.backgroundColor = .yellow
            case 5..<10:
                authorLabel.backgroundColor = .orange
            default:
                authorLabel.backgroundColor = .red
        }
    }
    
    // MARK: - Properties
    
    var post: Post? {
        didSet {
            updateSubviews()
        }
    }
    
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let latitudeLabel = UILabel()
    private let longitudeLabel = UILabel()
    
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
}
