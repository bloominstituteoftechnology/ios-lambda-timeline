//
//  FirebaseConvertible.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 BloomTech. All rights reserved.
//

import Foundation

protocol FirebaseConvertible {
    var dictionaryRepresentation: [String: Any] { get }
}
