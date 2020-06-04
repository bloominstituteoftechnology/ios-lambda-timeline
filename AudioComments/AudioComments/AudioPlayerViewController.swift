//
//  AudioPlayerViewController.swift
//  AudioComments
//
//  Created by Bhawnish Kumar on 6/2/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit
import AVFoundation
class AudioPlayerViewController: UIViewController {
    
    weak var delegate: AudioTableViewController!
    var recordingURL: URL?
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self
        }
    }
    var audioRecorder: AVAudioRecorder?
    
    var timer: Timer?
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var audioSlider: UISlider!
    @IBOutlet private var recordingButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTime.font = UIFont.monospacedDigitSystemFont(ofSize: currentTime.font.pointSize,
                                                               weight: .regular)
             durationTime.font = UIFont.monospacedDigitSystemFont(ofSize: durationTime.font.pointSize,
                                                                        weight: .regular)
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        try? prepareAudioSession()
        updateViews()
    }
    
    deinit {
        cancelTimer()
    }
    

    func startTimer() {
        timer?.invalidate() // import to invalidate the timer to start a new one to prevent multiple timers.
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            self.updateViews()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateViews() {
        playButton.isSelected = isPlaying
        recordingButton.isSelected = isRecording
        let elapsedTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0
        
        let timeRemaining = round(duration) - elapsedTime
        currentTime.text = timeIntervalFormatter.string(from: elapsedTime)
        durationTime.text = timeIntervalFormatter.string(from: timeRemaining)
        
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = Float(duration)
        audioSlider.value = Float(elapsedTime)
    }
    
    func play() {
        audioPlayer?.play()
        startTimer()
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
        cancelTimer()
        updateViews()
    }
    
    func togglePlayBack() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
        func prepareAudioSession() throws {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try session.setActive(true, options: []) // can fail if on a phone call, for instance            try session.setActive(true, options: []) // can fail if on a phone call, for instance
        }
        
        
        func createNewRecordingURL() -> URL {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
            let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
            
            //        print("recording URL: \(file)")
            
            return file
        }
        
        func startRecording() {
            let recordingURL = createNewRecordingURL()
            
            let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)! // if programmer error , add error mossage or log.
            audioRecorder = try? AVAudioRecorder(url: recordingURL, format: audioFormat)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            self.recordingURL = recordingURL
        }
        
        
        func requestPermissionOrStartRecording() {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    guard granted == true else {
                        print("We need microphone access")
                        return
                    }
                    
                    print("Recording permission has been granted!")
                    // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
                }
            case .denied:
                print("Microphone access has been blocked.")
                
                let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
                
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
        
        func stopRecording() {
            audioRecorder?.stop()
            updateViews()
        }
        
        func toggleRecording() {
            if isRecording {
                stopRecording()
                updateViews()
            } else {
                requestPermissionOrStartRecording()
            }
        }
        
        
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if let recordingURL = recordingURL {
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .short
            let date = df.string(from: Date())

            print("Send: \(recordingURL.absoluteString)")
            print(date)
            delegate?.audioElements.append((date, recordingURL))
         
        }

        navigationController?.popViewController(animated: true)
           }
           
           @IBAction func togglePlayback(_ sender: Any) {
            togglePlayBack()
           }
           
           @IBAction func updateCurrentTime(_ sender: UISlider) {
               
           }
           
           @IBAction func toggleRecording(_ sender: Any) {
            toggleRecording()
               
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

extension AudioPlayerViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print(error)
        }
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
}

extension AudioPlayerViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
        print("finished recording: \(recordingURL.path)")
            // this method to listen yourself when recording.
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL) // TODO: errors
            
        }
        
        updateViews()
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Record Error: \(error)")
        }
        updateViews()
    }
}


