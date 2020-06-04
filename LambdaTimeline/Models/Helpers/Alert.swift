//
//  Alert.swift
//  LambdaTimeline
//
//  Created by Kenny on 6/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//
import UIKit

enum Alert {
    static func withYesNoPrompt(title: String, message: String, vc: UIViewController, complete: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            complete(true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            complete(false)
        }))
        vc.present(alert, animated: true)
    }
}
