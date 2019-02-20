//
//  ImagePostTableViewCell.swift
//  LambdaTimeline
//
//  Created by Sergey Osipyan on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class ImagePostTableViewCell: UITableViewCell, PlayerDelegate, RecorderDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        player.delegate = self
        recorder.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        player.delegate = self
        recorder.delegate = self
    }

    
    let viewController = ViewController()
    var recordFile: Recorder?
    private let player = Player()
    private let recorder = Recorder()
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var play: UIButton!
    @IBAction func recordAction(_ sender: Any) {
        
        recorder.toggleRecording()
    }
    @IBAction func playAction(_ sender: Any) {
        
        player.playPause(song: recordFile?.currentFile)
    }
    
    
    
    func recorderDidChangeState(_ recorder: Recorder) {
        updateAudioViews()
    }
    
    func playerDidChangeState(_ playe: Player) {
        updateAudioViews()
    }
    private func updateAudioViews() {
        let isPlaying = player.isPlaying
        play.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        
        let isRecording = recorder.isRecording
        record.setTitle(isRecording ? "Stop" : "Record", for: .normal)
        
    }
    
}
