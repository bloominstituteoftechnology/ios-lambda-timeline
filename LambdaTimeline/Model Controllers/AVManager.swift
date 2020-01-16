//
//  AVManager.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-16.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class AVManager: AVManageableDelegate {

    static let shared = AVManager()

    private(set) var manageables = [AVManageable]()

    private init() {}

    func add(_ manageable: AVManageable) {
        guard !manageables.contains(where: { $0 === manageable }) else { return }

        manageables.append(manageable)
        manageable.delegate = self
    }

    func remove(_ manageable: AVManageable) {
        manageables.removeAll(where: { $0 === manageable })
        manageable.delegate = nil
    }

    func pauseAll() {
        manageables.forEach {
            if $0.isPlaying { $0.pause() }
        }
    }

    func removeAll() {
        manageables.forEach {
            $0.pause()
            $0.delegate = nil
        }
        manageables = []
    }

    // MARK: - Delegate

    func avManageableWillPlay(_ manageable: AVManageable) -> Bool {
        pauseAll()
        return true
    }
}
