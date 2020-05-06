//
//  RecorderViewController.swift
//  LambdaTimeline
//
//  Created by Lydia Zhang on 5/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    // Mark: - Delegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard let url = url else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            NSLog("Error: Did not finish record")
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayDidFinishPlaying.flag = \(flag)")
        
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error decoding audio: \(error)")
        }
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Error recording: \(error)")
        }
    }
    
    //property
    @IBOutlet var mainView: UIView!
    var audioView = Audio()

    var recorder: AVAudioRecorder?
    var url: URL?
    
    var player: AVAudioPlayer? {
        didSet {
            guard let player = player else {return}
            player.delegate = self
            player.isMeteringEnabled = true
            
        }
    }
    
    var isRecording: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
