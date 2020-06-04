//
//  Image+Convenience.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/4/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import Foundation
import CoreData

extension Image {
    @discardableResult
    convenience init(image: Data,
                     title: String,
                     latitude: Double,
                     longitide: Double,
                     date: Date = Date(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.image = image
        self.date = date
        self.title = title
        self.latitude = latitude
        self.longitude = longitide
    }
}
