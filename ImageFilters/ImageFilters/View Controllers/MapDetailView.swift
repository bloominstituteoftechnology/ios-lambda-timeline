//
//  MapDetailView.swift
//  ImageFilters
//
//  Created by Mark Poggi on 6/4/20.
//  Copyright © 2020 Mark Poggi. All rights reserved.
//

import UIKit

class MapDetailView: UIView {

    // MARK: - Properties
       var post: Post? {
           didSet {
               updateSubviews()
           }
       }

       private let titleLabel = UILabel()

       override init(frame: CGRect) {
           super.init(frame: frame)

           let titleStackView = UIStackView(arrangedSubviews: [titleLabel])
           let mainStackView = UIStackView(arrangedSubviews: [titleStackView])
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
            guard let post = post else { return }
            titleLabel.text = post.title
        }
    }

