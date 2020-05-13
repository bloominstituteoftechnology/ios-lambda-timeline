//
//  VideoPost.swift
//  VideoPost
//
//  Created by Jessie Ann Griffin on 5/12/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import Foundation
import CoreData

extension VideoPost {
    
    convenience init(title: String, url: URL,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.videoTitle = title
        self.videoURL = url.absoluteString
    }
}
