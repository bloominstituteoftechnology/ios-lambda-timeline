//
//  PostDetailView.swift
//  LambdaTimeline
//
//  Created by Karen Rodriguez on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//
import UIKit

class QuakeDetailView: UIView {

    // MARK: - Properties
    var post: Post? {
        didSet {
            updateSubviews()
        }
    }

    private let postImage = UIImageView()


    override init(frame: CGRect) {
        super.init(frame: frame)

        let placeDateStackView = UIStackView(arrangedSubviews: [magnitudeLabel, dateLabel])
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
    }
}
