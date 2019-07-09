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
        let documentsDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
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
        //get audio url
        //  let sampleAudioUrl = Bundle.main.url(forResource: "piano", withExtension: "mp3")!

        guard let recordingUrl = recordingUrl else {return}

        if isPlaying {
            player?.stop()
            return
        }

        //create player and tell it to start playing
        do {
            //Set up the player with the sample audio file
            player = try AVAudioPlayer(contentsOf: recordingUrl)

            player?.play()

            //the VC adding itself as the observer of the delegate method.
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
    }

    @IBAction func recordButtonPressed(_ sender: UIButton) {

        if isRecording {
            recorder?.stop()
            return
        }
        do {
            //Choose the format
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
}

