//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Karen Rodriguez on 5/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import FirebaseStorage

class AudioCommentTableViewCell: UITableViewCell {

    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self
        }
    }

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    var audioURL: String?

    // MARK: - Outlets
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playButton.tintColor = .gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func loadSound() {
        guard let url = audioURL else { return }
        let httpsReference = Storage.storage().reference(forURL: url)

    }

    // MARK: - Playback

//    func loadAudio() {
//        let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!
//
//        audioPlayer = try? AVAudioPlayer(contentsOf: songURL)
//        audioPlayer?.isMeteringEnabled = true
//    }

//    func prepareAudioSession() throws {
//        let session = AVAudioSession.sharedInstance()
//        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
//        try session.setActive(true, options: []) // can fail if on a phone call, for instance
//    }
//
//    func play() {
//        audioPlayer?.play()
//    }
//
//    func pause() {
//        audioPlayer?.pause()
//    }
//
//    func updateViews() {
//        playButton.isSelected = isPlaying
//    }
}
//
//extension AudioCommentTableViewCell: AVAudioPlayerDelegate {
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        updateViews()
//    }
//    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
//        if let error = error {
//            print("Audio Player Decode Error: \(error)")
//        }
//        updateViews()
//    }
//}
