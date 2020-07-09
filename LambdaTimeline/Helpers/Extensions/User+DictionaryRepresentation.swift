//
//  User+DictionaryRepresentation.swift
//  LambdaTimeline
//
//  Created by Michael Stoffer on 9/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

extension User {
    
    private static let uidKey = "uid"
    private static let displayNameKey = "displayName"
    
    var dictionaryRepresentation: [String: String] {
        return [User.uidKey: uid,
                User.displayNameKey: displayName ?? "No display name"]
    }
}
