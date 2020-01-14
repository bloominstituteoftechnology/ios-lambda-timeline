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

    // MARK: - Helper Methods

    private func setUpSubViews() {

    }
}
