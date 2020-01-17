//
//  PostAnnotationView.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-16.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class PostAnnotationView: UIView {
    var post: Post? {
        didSet { updateSubviews() }
    }

    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        authorLabel.setContentHuggingPriority(.defaultLow+1, for: .horizontal)

        let placeDateStackView = UIStackView(arrangedSubviews: [titleLabel])
        placeDateStackView.spacing = UIStackView.spacingUseSystem
        let latLonStackView = UIStackView(arrangedSubviews: [authorLabel, dateLabel])
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

    // MARK: - Private

    private func updateSubviews() {
        guard let post = post else { return }

        let title = post.title
        titleLabel.text = title
        dateLabel.text = DateFormatter.mapAnnotationFormatter
            .string(from: post.timestamp)
        authorLabel.text = post.author.displayName
    }
}
