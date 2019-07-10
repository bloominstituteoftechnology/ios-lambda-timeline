//
//  RecorderViewController.swift
//  LambdaTimeline
//
//  Created by Jonathan Ferrer on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//


import UIKit
import AVFoundation

class RecorderViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {


    private func newRecordingUrl() -> URL {
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }

    private func updateButtons() {

        let playButtonTitle = isPlaying ? "Stop Playing" : "Play"
        playButton.setTitle(playButtonTitle, for: .normal)

        let recordButtonTitle = isRecording ? "Stop Recoring" : "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)

    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateButtons()
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        updateButtons()

        recordingUrl = recorder.url
    }


    @IBAction func playButtonPressed(_ sender: UIButton) {
        guard let recordingUrl = recordingUrl else {return}

        if isPlaying {
            player?.stop()
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: recordingUrl)
            player?.play()
            player?.delegate = self
        } catch {
            NSLog("Error attmepting to start playing audio: \(error)")
        }

        updateButtons()

    }

     @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

     @IBAction func doneButtonPressed(_ sender: UIButton) {
        guard let recordingUrl = recordingUrl,
        let data = try? Data(contentsOf: recordingUrl),
        let post = post,
        let postController = postController else { return }
        postController.addComment(with: data, to: post) {
            
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func recordButtonPressed(_ sender: UIButton) {

        if isRecording {
            recorder?.stop()
            return
        }
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingUrl(), format: format)
            recorder?.record()
            recorder?.delegate = self
        } catch {
            NSLog("Unable to start recoring: \(error)")
        }
        updateButtons()

    }

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder?



    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    var recordingUrl: URL?

    var post: Post!
    var postController: PostController!
}

