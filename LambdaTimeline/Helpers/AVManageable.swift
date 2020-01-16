//
//  AVManageable.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-16.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

protocol AVManageable: AnyObject {
    var delegate: AVManageableDelegate? { get set }
    var isPlaying: Bool { get }

    func pause()
}

protocol AVManageableDelegate: AnyObject {
    func avManageableWillPlay(_ manageable: AVManageable) -> Bool
}

//class AnyAVManageable<T: AVManageable>: AVManageable, Hashable {
//    static func == (lhs: AnyAVManageable<T>, rhs: AnyAVManageable<T>) -> Bool {
//        lhs._manageable == rhs._manageable
//    }
//
//    private var _manageable: T
//
//    var delegate: AVManageableDelegate? {
//        get { _manageable.delegate
//        } set { _manageable.delegate = newValue }
//    }
//    var isPlaying: Bool { _manageable.isPlaying }
//
//    init(_ manageable: T) {
//        self._manageable = manageable
//    }
//
//    func pause() {
//        _manageable.pause()
//    }
//}
