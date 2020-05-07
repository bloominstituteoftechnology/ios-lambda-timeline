//
//  RecordViewController.swift
//  AudioComments
//
//  Created by Tobi Kuyoro on 06/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!

    // MARK: - Properties

    var recording: Recording?
    var recordingController: RecordingController?

    var recordingTitle: String?
    var recordingURL: URL?
    var timer: Timer?

    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?

    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()

    // MARK: - View Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        timerMonoSpacedFont()

        if recording == nil  {
            updateViews()
        } else {
            recordingExistsView()
        }

        try? prepareAudioSession()

        recordingLabel.isHidden = true
    }

    // MARK: - View Related Methods

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

        recordButton.isSelected = isRecording
    }

    func recordingExistsView() {
        guard let recording = recording else { return }

        playButton.isSelected = isPlaying

        let currentTime = recording.currentTime
        let duration = recording.duration
        let timeRemaining = round(duration) - currentTime

        timeElapsedLabel.text = timeIntervalFormatter.string(from: currentTime) ?? "00:00"
        timeRemainingLabel.text = "-" + (timeIntervalFormatter.string(from: timeRemaining) ?? "00:00")

        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        timeSlider.value = Float(currentTime)

        stoppedRecordingView()
    }

    private func timerMonoSpacedFont() {
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize, weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize, weight: .regular)
    }

    private func isRecordingView() {
        recordingLabel.isHidden = false
        timeElapsedLabel.isHidden = true
        timeRemainingLabel.isHidden = true
        timeSlider.isHidden = true
    }

    private func stoppedRecordingView() {
        recordingLabel.isHidden = true
        timeElapsedLabel.isHidden = false
        timeRemainingLabel.isHidden = false
        timeSlider.isHidden = false
    }

    // MARK: - Timer Methods

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

    // MARK: - Recording Methods

    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else { return }

                let alert = UIAlertController(title: "Start Recording", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        case .denied:
            let alert = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })

            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

            present(alert, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }

    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        return file
    }

    func startRecording() {
        let recordingURL = createNewRecordingURL()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!

        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL, format: format)
        } catch {
            NSLog("Error assigning contents of the recording url and format to the audio player: \(error)")
        }

        audioRecorder?.delegate = self
        audioRecorder?.record()
        self.recordingURL = recordingURL
        updateViews()

        startTimer()
    }

    func stopRecording() {
        audioRecorder?.stop()
        updateViews()
        cancelTimer()
    }

    // MARK: - Playback Methods

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

    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: [])
    }

    // MARK: - IBActions

    @IBAction func updateCurrentTime(_ sender: Any) {
        if isPlaying {
            pause()
        }

        audioPlayer?.currentTime = TimeInterval(timeSlider.value)
        updateViews()
    }

    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    @IBAction func toggleRecording(_ sender: Any) {
        if isRecording {
            stopRecording()
            stoppedRecordingView()
        } else {
            requestPermissionOrStartRecording()
            isRecordingView()
        }
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let duration = audioPlayer?.duration,
            let currentTime = audioPlayer?.currentTime,
            let recordingURL = recordingURL else { return }

        let alert = UIAlertController(title: "What do you want to name this recording?", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)

        var recordingTitle = ""

        let submit = UIAlertAction(title: "Submit", style: .default) { _ in
            if let response = alert.textFields?.first?.text, !response.isEmpty {
                recordingTitle = response
                self.recordingController?.createRecording(called: recordingTitle,
                                                          duration: duration,
                                                          currentTime: currentTime,
                                                          url: recordingURL)

                self.navigationController?.popToRootViewController(animated: true)
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(submit)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

extension RecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag,
            let recordingURL = recordingURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
            } catch {
                NSLog("Error assigning contents of the recording url to the audio player: \(error)")
            }
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

extension RecordViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }

        updateViews()
    }
}
