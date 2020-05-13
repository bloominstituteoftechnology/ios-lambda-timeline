//
//  AudioRecorderController.swift
//  AudioComments
//
//  Created by Alex Thompson on 5/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderController: UIViewController {
    
    var recording = Recording(name: "Alex")
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordings.append(recording)
        tableView.register(UINib(nibName: "AudioCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioCell")
        
    }
    
    weak var timer: Timer?
    
    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?
    
    var recordings: [Recording] = []
    
    
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var recordButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    
    
    private lazy var timeInternalFormatter: DateComponentsFormatter = {
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    func updateViews() {
        
    }
    
    func prepareAudioSession() throws {
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // Can fail if you're on a phone call
    }
    
    func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            // MARK: - TODO, ADD IN START TIMER FUNCTION WHEN READY!!!!!!!!!
            // start time when function is programmed
            // startTimer()
        } catch {
            print("There was an error playing back audio: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        // MARK: - TODO NEED TO ADD CANCEL TIMER CALL
        //cancelTimer()
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(recordingURL!)")
        
        return file
    }
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("WE NEED MIC ACCESS PRETTY PLEASE WITH CHERRY ON TOP")
                    return
                }
                
                print("Recording permission has been granted!")
            }
        case .denied:
            print("Microphone acces has been blocked!")
            
            let alertController = UIAlertController(title: "Microphone access denied 😭", message: "Please allow this app to access your mic please.... please.... please ", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    
    func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Error!")
            return
        }
        
        recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            //audioRecorder.delegate = self
            audioRecorder?.record()
        } catch {
            preconditionFailure("Audio recorder could not be created with url: \(recordingURL)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
    }
}

extension AudioRecorderController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
        }
        audioPlayer = nil
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
    }
}

extension AudioRecorderController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        //cancelTimer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print("An error occured: \(e.localizedDescription)")
        }
    }
}

extension AudioRecorderController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recording = recordings[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! AudioCommentTableViewCell
        
        cell.nameLabel.text = recording.name
        return cell
    }
}
