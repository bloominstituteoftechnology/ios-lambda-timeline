//
//  CommentTableViewController.swift
//  AudioComments
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class CommentTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .interactive
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    lazy var audioCommentView: AudioCommentView = {
        let audioCommentView = AudioCommentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        audioCommentView.delegate = self
        return audioCommentView
    }()
    
    override var inputAccessoryView: UIView? {
        return audioCommentView
    }
    
    override var canBecomeFirstResponder: Bool {
        true
    }

}

extension CommentTableViewController: AudioCommentViewDelegate {
    func sendAudioComment(with url: URL) {
        print("Sending audio comment with url: \(url)")
    }
    
    func sendTextualComment(with text: String) {
        print("Sending text comment: \(text)")
    }
}


//    private func requestPermissionOrStartRecording() {
//        switch AVAudioSession.sharedInstance().recordPermission {
//        case .undetermined:
//            AVAudioSession.sharedInstance().requestRecordPermission { granted in
//                guard granted == true else {
//                    print("We need microphone access")
//                    return
//                }
//
//                print("Recording permission has been granted!")
//                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
//            }
//        case .denied:
//            print("Microphone access has been blocked.")
//
//            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
//
//            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
//                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//            })
//
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
//
//            present(alertController, animated: true, completion: nil)
//        case .granted:
//            startRecording()
//        @unknown default:
//            break
//        }
//    }
