//
//  FilteredImage+Convenience.swift
//  ImageFilterEditor
//
//  Created by denis cedeno on 5/7/20.
//  Copyright © 2020 DenCedeno Co. All rights reserved.
//

import Foundation
import CoreData

extension FilteredImage {
    @discardableResult
    convenience init(image: Data,
                     comments: String,
                     date: Date = Date(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.image = image
        self.date = date
        self.comments = comments
    }
}
