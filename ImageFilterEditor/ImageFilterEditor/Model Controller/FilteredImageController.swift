//
//  FilteredImageController.swift
//  ImageFilterEditor
//
//  Created by denis cedeno on 5/7/20.
//  Copyright © 2020 DenCedeno Co. All rights reserved.
//

import Foundation
import CoreData

class FilteredImageController {
    
    var imagePosts: [FilteredImage] = []

    @discardableResult
    func appendFilteredImage(images: Data, comments: String, lattitude: Double, longitude: Double) -> FilteredImage {
        
        let imagePost = FilteredImage(image: images, comments: comments, lattitude: lattitude, longitide: longitude, date: Date())
        imagePosts.append(imagePost)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            fatalError("Could not save image post: \(error)")
        }
        return imagePost

    }
}

