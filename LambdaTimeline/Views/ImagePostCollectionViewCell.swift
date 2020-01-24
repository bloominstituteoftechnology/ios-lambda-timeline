//
//  ImagePostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class ImagePostCollectionViewCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    
    let locationBackground = UIView()
    let locationName = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
        configureLocationNameLabelAndBackground()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let post = post else { return }
    
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
        let location = CLLocation(latitude: post.latitude ?? 0, longitude: post.longitude ?? 0)
        
        fetchCityAndCountry(from: location) { (city, country, error) in
            guard let city = city, let country = country, error == nil else { return }
            DispatchQueue.main.async {
                self.locationName.text = "\(city), \(country)"
            }
        }
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality, placemarks?.first?.country, error)
        }
    }

    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
        labelBackgroundView.layer.borderWidth = 0.5
        labelBackgroundView.clipsToBounds = true
    }
    
    func configureLocationNameLabelAndBackground() {
        addSubview(locationBackground)
        locationBackground.addSubview(locationName)
        
        locationBackground.translatesAutoresizingMaskIntoConstraints = false
        locationName.translatesAutoresizingMaskIntoConstraints = false
        
        locationBackground.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        locationName.textColor = .white
        
        NSLayoutConstraint.activate([
            locationBackground.topAnchor.constraint(equalTo: self.topAnchor),
            locationBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            locationBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            locationBackground.heightAnchor.constraint(equalToConstant: 40),
            
            locationName.centerYAnchor.constraint(equalTo: locationBackground.centerYAnchor),
            locationName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8)
        ])
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    

}
