//
//  AudioCommentsViewController.swift
//  LambdaTimeline
//
//  Created by Elizabeth Wingate on 4/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentsViewController: UIViewController,  AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let withIdentifier = "cell"
     var recordings = [URL]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: withIdentifier , for: indexPath)
        cell.textLabel?.text = recordings[indexPath.row].lastPathComponent
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = recordings[indexPath.row]
        do {
            player = try AVAudioPlayer(contentsOf: cell)
            player?.delegate = self
            player?.play()
            
        } catch {
            NSLog("Unable to start playing audio: \(error)")
        }
        updateButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewFiles.delegate = self
        viewFiles.dataSource = self
        viewFiles.reloadData()
        listRecordings()
        
    }
    
    var post: Post!
    var postController: PostController!
    
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var recordingURL: URL?
    private var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    func listRecordings() {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
    let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
      self.recordings = urls.filter({ (name: URL) -> Bool in
                return name.pathExtension == "caf"
                
        })
    } catch {
            print(error.localizedDescription)
            print("Could not list Recordings")
    }
    }
    
    @IBAction func play(_ sender: Any) {
        defer {updateButtons()}
        
        guard let url = recordingURL else { return }
           updateViews()
        
        guard !isPlaying else {
            player?.stop()
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            startPlayTime()
            
        } catch {
            NSLog("unable to start playing audio:\(error)")
        }
        updateButtons()
    }
    private var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    @IBAction func record(_ sender: Any) {
        guard !isRecording else {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
            startPlayTime()
            updateViews()
        }catch {
            NSLog("unable to record\(error)")
            
        }
    }
    
    private func newRecordingURL()-> URL {
        let fileManager = FileManager.default
        let documentDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask , appropriateFor: nil, create: true)

        let newRecordingURL = documentDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
        return newRecordingURL
    }
    
    private func updateButtons(){
        let playButtonTitle = isPlaying ? "Stop Playing" : "Play"
        playButton.setTitle(playButtonTitle, for: .normal)
        let recordButtonTitle = isRecording ? "Stop Recording": "Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingURL = recorder.url
        self.recorder = nil
        updateButtons()
    }
    
    @IBOutlet weak var name: UILabel!
    
    @IBAction func sliderChanged(_ sender: Any) {
        let duration = player?.duration ?? 0
        let sliderTime = TimeInterval(timeSlider.value) * duration
        player?.currentTime = sliderTime
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var viewFiles: UITableView!

    func updateViews() {
        let currentTime = player?.currentTime ?? 0
        let duration = player?.duration ?? 0
        timeSlider.value = Float(currentTime / duration)
    }

    private func startPlayTime() {
        playTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] (timer) in
            self?.updateViews()
        }
    }

    private var playTimer: Timer? {
        willSet {
            playTimer?.invalidate()
        }
    }
}
