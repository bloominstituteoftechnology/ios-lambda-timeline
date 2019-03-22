//
//  RecordAudioViewController.swift
//  LambdaTimeline
//
//  Created by Moses Robinson on 3/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        clearDirectoryOfRecordings()
    }
    
    // MARK: - Actions
    
    @IBAction func record(_ sender: Any) {
        
        guard !isPlaying else { return }
        
        if isRecording {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording")
        }
        
        updateButtons()
    }
    
    @IBAction func play(_ sender: Any) {
        
        guard !isRecording else { return }
        
        guard let recordingURL = recordingURL else { return }
        
        if isPlaying {
            player?.stop()
            updateButtons()
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: recordingURL)
            player?.play()
            
            player?.delegate = self
        } catch {
            NSLog("Error attempting to start playing audio: \(error)")
        }
        
        updateButtons()
    }
    
    @IBAction func cancelPost(_ sender: Any) {
      //  clearDirectoryOfRecordings()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postRecording(_ sender: Any) {
        
        guard var post = post,
            let audioURL = recordingURL else { return }
        
        postController?.addAudioComment(with: audioURL, to: &post)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Functions
    
    private func clearDirectoryOfRecordings() {
        
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let documentURLs = try! FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        var recordingURLs = documentURLs.filter({ $0.pathExtension == "caf" })
        
        recordingURLs.removeAll()
    }
    
    private func updateButtons() {
        
        let playButtonTitle = isPlaying ? "Stop Playing" : "Play Back"
        playButton.setTitle(playButtonTitle, for: .normal)
        
        let recordButtonTitle = isRecording ? "Stop Recording" : "Record Comment"
        recordButton.setTitle(recordButtonTitle, for: .normal)
    }
    
    private func newRecordingURL() -> URL {
        
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    // MARK: - AVAudio Delegates
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateButtons()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        updateButtons()
        
        recordingURL = recorder.url
    }
    
    // MARK: - Properties
    
    var postController: PostController?
    var post: Post?
    
    var recordingURL: URL?
    
    var player: AVAudioPlayer?
    
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    private var recorder: AVAudioRecorder?
    
    var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
}
