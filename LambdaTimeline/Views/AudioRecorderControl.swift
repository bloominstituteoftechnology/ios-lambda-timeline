//
//  AudioRecorderControl.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-14.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable
class AudioRecorderControl: UIControl {

    // MARK: - UI Elements

    private var recordButton = UIButton()
    private var timestampLabel = UILabel()

    private var stackView: UIStackView!

    // MARK: - Audio Properties

    private(set) var audioFileURL: URL?

    var isRecording: Bool { audioRecorder?.isRecording ?? false }
    var elapsedTime: TimeInterval { audioRecorder?.currentTime ?? 0 }

    private var audioRecorder: AVAudioRecorder?
    private var uiUpdateTimer: Timer?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubViews()
    }

    // MARK: - UI Actions

    @objc
    private func recordButtonPressed(_ sender: Any) {
        toggleRecord()
    }

    // MARK: - Recording API

    func toggleRecord() {

    }

    func record() {
        guard
            let docs = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first,
            let format = AVAudioFormat(standardFormatWithSampleRate: 44_100,
                                       channels: 1)
            else {
                print("Cannot record; missing docs folder!")
        }
        let name = ISO8601DateFormatter.string(
            from: Date(),
            timeZone: .autoupdatingCurrent,
            formatOptions: [.withInternetDateTime])
        let file = docs.appendingPathComponent(name).appendingPathExtension("caf")
        audioFileURL = file
        print("recording to file: \(file)")


        do {
            audioRecorder = try AVAudioRecorder(url: file, format: format)
        } catch {
            print("error setting up audio recorder: \(error)")
        }
//        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
        startUIUpdateTimer()
    }

    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
        killUIUpdateTimer()
    }

    // MARK: - Helper Methods

    private func updateViews() {

    }

    private func startUIUpdateTimer() {

    }

    private func killUIUpdateTimer() {

    }

    @objc
    private func updateUITimer(_ timer: Timer) {
        updateViews()
    }

    private func setUpSubViews() {

    }
}
