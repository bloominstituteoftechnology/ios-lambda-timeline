//
//  AudioControl.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-14.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable
class AudioPlaybackControl: UIControl {

    // MARK: - UI Elements

    private(set) var playPauseButton = UIButton()
    private(set) var timeSlider = UISlider()

    private var timestampLabel = UILabel()
    private var timeRemainingLabel = UILabel()

    private var verticalStack: UIStackView!
    private var sliderStack: UIStackView!

    private var timeFormatter: DateComponentsFormatter {
        DateComponentsFormatter.audioPlayerTimeFormatter
    }

    // MARK: - Audio Properties

    private(set) var audioFileURL: URL?

    var isPlaying: Bool { audioPlayer?.isPlaying ?? false }
    var elapsedTime: TimeInterval { audioPlayer?.currentTime ?? 0 }
    var totalDuration: TimeInterval { audioPlayer?.duration ?? 0 }
    var timeRemaining: TimeInterval { totalDuration - elapsedTime }

    private var audioPlayer: AVAudioPlayer?
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

    private func setUpSubViews() {
    }
