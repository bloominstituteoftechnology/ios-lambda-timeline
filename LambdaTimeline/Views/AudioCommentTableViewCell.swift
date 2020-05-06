//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Karen Rodriguez on 5/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import FirebaseStorage
import AVFoundation

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

    var timer: Timer?

    // MARK: - Outlets
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playButton.tintColor = .gray
        updateViews()
        try? prepareAudioSession()
        loadSound()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    deinit {
        timer?.invalidate()
    }

    private func loadSound() {
        guard let url = audioURL else { return }
        let httpsReference = Storage.storage().reference(forURL: url)
        let localURL = createLocalURL()

        let downloadTask = httpsReference.write(toFile: localURL) { url, error in
            if let error = error {
                NSLog("Error doing loading of soudn idk HEREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: \(error)")
                return
            }

            guard let url = url else {
                NSLog("error unqrapping url")
                return
            }
            DispatchQueue.main.async {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.playButton.tintColor = .blue
                } catch {
                    NSLog("Error assigning audioplayer with unwrapped url \(error)")
                }
            }
        }

        downloadTask.observe(.resume) { snapshot in
            print("stuff happeningggggggg")
        }
    }

    // MARK: - Timer

    func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }

            self.updateViews()
        }
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Recording

    func createLocalURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        print("recording URL: \(file)")

        return file
    }

    // MARK: - Playback

    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }

    func play() {
        audioPlayer?.play()
    }

    func pause() {
        audioPlayer?.pause()
    }

    func updateViews() {
        playButton.isSelected = isPlaying
    }

    @IBAction func playButtonTouched(_ sender: Any) {
        if isPlaying {
            pause()
            updateViews()
        } else {
            play()
            updateViews()
        }
    }

}

extension AudioCommentTableViewCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Decode Error: \(error)")
        }
        updateViews()
    }
}
