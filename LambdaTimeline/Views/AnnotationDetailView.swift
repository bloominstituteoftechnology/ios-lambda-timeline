//
//  AnnotationDetailView.swift
//  LambdaTimeline
//
//  Created by Cora Jacobson on 11/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AnnotationDetailView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
                
        let dateSubtitleStackView = UIStackView(arrangedSubviews: [dateLabel, subtitleLabel])
        dateSubtitleStackView.spacing = UIStackView.spacingUseSystem
        let mainStackView = UIStackView(arrangedSubviews: [imageView, dateSubtitleStackView])
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
        guard let pin = pin else { return }
        dateLabel.text = dateFormatter.string(from: pin.date)
        subtitleLabel.text = pin.subtitle
        imageView.image = pin.image
        let ratio = pin.image?.ratio ?? 1
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: (200 * ratio)).isActive = true
    }
    
    // MARK: - Properties
    var pin: Annotation? {
        didSet {
            updateSubviews()
        }
    }
    
    let dateLabel = UILabel()
    let subtitleLabel = UILabel()
    let imageView = UIImageView()
    
    private lazy var dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .short
        return result
    }()

}
