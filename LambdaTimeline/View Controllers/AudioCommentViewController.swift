//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


class AudioCommentViewController: UIViewController {

    private lazy var player = Player()
    private lazy var recorder = Recorder()
    
    @IBOutlet weak var recordProperties: UIButton!
    @IBOutlet weak var playProperties: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        recorder.delegate = self
        
    }
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        recorder.toggleRecording()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
//        guard let recorder = recorder, let player = player else { print("error: \(#line)"); return }
//        if recorder.isRecording {
//            recorder.stop()
//        } else if player.isPlaying {
//            player.pause()
//        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        //hide the play button until the until the record button has been pressed and stopped.
        player.playPause()
    }
    
    func updateViews(){
        let isPlaying = player.isPlaying
        playProperties.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        
        let isRecording = recorder.isRecording
        recordProperties.setTitle(isRecording ? "Cancel" : "Record", for: .normal)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AudioCommentViewController: PlayerDelegate {
    func playerDidChangeState(player: Player) {
        updateViews()
    }
    
    
}

extension AudioCommentViewController: RecorderDelegate {
    func recorderDidChangeState(recorder: Recorder) {
        updateViews()
    }
    
    
}
