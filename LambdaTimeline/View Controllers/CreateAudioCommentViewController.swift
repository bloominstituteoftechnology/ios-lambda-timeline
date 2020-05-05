//
//  CreateAudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Karen Rodriguez on 5/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CreateAudioCommentViewController: UIViewController {

    // MARK: - Properties

    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
        }
    }

    private var timer: Timer?

    // MARK: - View Controller

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension CreateAudioCommentViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        <#code#>
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        <#code#>
    }
}
