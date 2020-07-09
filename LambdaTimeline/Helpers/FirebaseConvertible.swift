//
//  FirebaseConvertible.swift
//  LambdaTimeline
//
//  Created by Michael Stoffer on 9/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol FirebaseConvertible {
    var dictionaryRepresentation: [String: Any] { get }
}
