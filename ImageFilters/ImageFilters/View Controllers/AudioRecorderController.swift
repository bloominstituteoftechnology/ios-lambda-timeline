//
//  AudioRecorderController.swift
//  AudioComments
//
//  Created by Mark Poggi on 6/2/20.
//  Copyright © 2020 Mark Poggi. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class AudioRecorderController: UIViewController {

    // MARK: - Properties

    var postController: PostController!
    var post: Post?
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    // MARK: - Outlets

    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var audioVisualizer: AudioVisualizer!
    @IBOutlet var titleField: UITextField?


    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                                 weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        loadAudio()
        updateViews()
        try? prepareAudioSession()
    }

    deinit {
        cancelTimer()
    }

    private func updateViews() {
        playButton.isSelected = isPlaying

        let currentTime = audioPlayer?.currentTime ?? 0.0
        let duration = audioPlayer?.duration ?? 0.0

        let timeRemaining = round(duration) - currentTime

        timeElapsedLabel.text = timeIntervalFormatter.string(from: currentTime) ?? "00:00"
        timeRemainingLabel.text = "-" + (timeIntervalFormatter.string(from: timeRemaining) ?? "00:00")

        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(currentTime)

        // Recording
        recordButton.isSelected = isRecording

        guard let post = post,
            let titleField = titleField else {
                return
        }
        titleField.text = post.title
        recordingURL = post.recordingURL

    }

    // MARK: - Timer

    private var timer: Timer?

    func startTimer() {
        timer?.invalidate() // Cancel a timer before you start a new one!

        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }

            self.updateViews()

            if let audioRecorder = self.audioRecorder,
                self.isRecording == true {

                audioRecorder.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioRecorder.averagePower(forChannel: 0))

            }
            
            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {

                audioPlayer.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
            }
        }
    }

    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Playback

    var audioPlayer: AVAudioPlayer? {
        didSet {
            audioPlayer?.delegate = self // tell me when it finishes playing/errors.
            audioPlayer?.isMeteringEnabled = true
        }
    }

    func loadAudio() {
        let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!

        // TODO: Do more error checking and fail early if programmer error,
        // or present a message to the user.  Do Catch or Guard Let.
        audioPlayer = try? AVAudioPlayer(contentsOf: songURL) // will be nil if this fails
    }


    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }


    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    func togglePlayback() { // app/business logic
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func play() {
        audioPlayer?.play() // don't crash if player is nil ... if nothig to play, just don't do anything.
        startTimer()
        updateViews()
    }

    func pause() {
        audioPlayer?.pause()
        cancelTimer()
        updateViews()
    }

    // MARK: - Recording

    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?

    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        print("recording URL: \(file)")

        return file
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

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            requestPermissionOrStartRecording()

        }
    }

    func startRecording() {
        let recordingURL = createNewRecordingURL()

        //44,1000 hertz = 44.1 kHZ = FM / CD Audio Quality
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44.1, channels: 1)!

        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: audioFormat)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
        self.recordingURL = recordingURL
        updateViews()
    }

    func stopRecording() {
        audioRecorder?.stop()
        updateViews()
        cancelTimer()
    }

    // MARK: - Actions

    @IBAction func togglePlayback(_ sender: Any) {
        togglePlayback()
    }

    @IBAction func updateCurrentTime(_ sender: UISlider) {
        if isPlaying {
            pause()
        }

        audioPlayer?.currentTime = TimeInterval(timeSlider.value)
        updateViews()
    }

    @IBAction func toggleRecording(_ sender: Any) {
        toggleRecording()
    }

    @IBAction func cancelRecording(_ sender: Any) {
        cancelTimer()
        audioRecorder?.stop()
        audioRecorder?.deleteRecording()
        
        navigationController?.popViewController(animated: true)
    }

    @IBAction func saveRecording(_ sender: Any) {
        guard let title = titleField?.text, !title.isEmpty,
            let url = recordingURL else { return }

        postController.createPost(title: title, url: url)
        print(postController.posts.count)
        navigationController?.popViewController(animated: true)

        dismiss(animated: true, completion: nil)

    }
}

// MARK: - Extensions

extension AudioRecorderController: AVAudioPlayerDelegate {
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

extension AudioRecorderController: UITextFieldDelegate {
    // Question
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // calculateValues()
        return true // false if not valid input
    }
}

extension AudioRecorderController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            print("Finished recording: \(recordingURL.path)")
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL) // TODO: Errors
        }

        updateViews()
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Error recording: \(error)")
        }
        updateViews()
    }
}



