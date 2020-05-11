//
//  VoiceRecorderViewController.swift
//  AudioComments
//
//  Created by Joshua Rutkowski on 5/10/20.
//  Copyright © 2020 Josh Rutkowski. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceRecorderViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var handleView: UIView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var audioVisualizer: AudioVisualizer!
    
    // MARK: - Properties
    var backingImage: UIImage?
    var cardViewState: CardViewState = .normal
    var cardPanStartingTopConstant : CGFloat = 30.0
    weak var timer: Timer?
    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            updateViews()
        }
    }
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    
    
    //MARK: - View Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCardView()
        setupDimmerView()
        setupViewPanning()
        setupHandleView()
        
        backingImageView.image = backingImage
        
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                                 weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        loadAudio()
        updateViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showCard()
    }
    
    func updateViews() {
        playButton.isEnabled = !isRecording
        recordButton.isEnabled = !isPlaying
        timeSlider.isEnabled = !isRecording
        
        playButton.isSelected = isPlaying
        recordButton.isSelected = isRecording
        
        if !isRecording {
            let elapsedTime = audioPlayer?.currentTime ?? 0
            let duration = audioPlayer?.duration ?? 0
            let timeRemaining = duration.rounded() - elapsedTime
            
            timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
            
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = Float(duration)
            timeSlider.value = Float(elapsedTime)
            
            timeRemainingLabel.text = "-" + timeIntervalFormatter.string(from: timeRemaining)!
        } else {
            let elapsedTime = audioRecorder?.currentTime ?? 0
            
            timeElapsedLabel.text = "--:--"
            
            timeSlider.minimumValue = 0
            timeSlider.maximumValue = 1
            timeSlider.value = 0
            
            timeRemainingLabel.text = timeIntervalFormatter.string(from: elapsedTime)!
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    //MARK: - Setup Views
    private func setupCardView() {
        // round the top left and top right corner of card view
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 10.0
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // hide the card view at the bottom when the View first load
        if let safeAreaHeight = view?.window?.safeAreaLayoutGuide.layoutFrame.size.height,
            let bottomPadding = view?.window?.safeAreaInsets.bottom {
            cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
        }
    }
    
    func setupDimmerView() {
        // set dimmerview to transparent
        dimmerView.alpha = 0.0
        
        // dimmerViewTapped() will be called when user tap on the dimmer view
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerViewTapped(_:)))
        dimmerView.addGestureRecognizer(dimmerTap)
        dimmerView.isUserInteractionEnabled = true
    }
    
    func setupViewPanning() {
        
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        viewPan.delaysTouchesBegan = false
        viewPan.delaysTouchesEnded = false
        
        self.view.addGestureRecognizer(viewPan)
    }
    
    func setupHandleView() {
        
        handleView.clipsToBounds = true
        handleView.layer.cornerRadius = 3.0
        
        
    }
    
    //MARK: - Animations
    
    enum CardViewState {
        case expanded
        case normal
    }
    
    private func showCard(atState: CardViewState = .normal) {
        self.view.layoutIfNeeded()
        if let safeAreaHeight = view?.window?.safeAreaLayoutGuide.layoutFrame.size.height,
            let bottomPadding = view?.window?.safeAreaInsets.bottom {
            
            if atState == .expanded {
                // if state is expanded, top constraint is 30pt away from safe area top
                cardViewTopConstraint.constant = 400.0
            } else {
                cardViewTopConstraint.constant = (safeAreaHeight + bottomPadding) / 1.2
            }
            
            cardPanStartingTopConstant = cardViewTopConstraint.constant
        }
        
        let showCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
            self.view.layoutIfNeeded()
        })
        
        showCard.addAnimations {
            self.dimmerView.alpha = 0.7
        }
        
        // run the animation
        showCard.startAnimation()
    }
    
    private func hideCardAndGoBack() {
        self.view.layoutIfNeeded()
        
        if let safeAreaHeight = view?.window?.safeAreaLayoutGuide.layoutFrame.size.height,
            let bottomPadding = view?.window?.safeAreaInsets.bottom {
            
            // move the card view to bottom of screen
            cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
        }
        
        let hideCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
            self.view.layoutIfNeeded()
        })
        
        hideCard.addAnimations {
            self.dimmerView.alpha = 0.0
        }
        
        hideCard.addCompletion({ position in
            if position == .end {
                if(self.presentingViewController != nil) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        })
        
        // run the animation
        hideCard.startAnimation()
    }
    
    private func dimAlphaWithCardTopConstraint(value: CGFloat) -> CGFloat {
        let fullDimAlpha : CGFloat = 0.7
        
        guard let safeAreaHeight = view?.window?.safeAreaLayoutGuide.layoutFrame.size.height,
            let bottomPadding = view?.window?.safeAreaInsets.bottom else {
                return fullDimAlpha
        }
        
        let fullDimPosition = (safeAreaHeight + bottomPadding) / 2.0
        let noDimPosition = safeAreaHeight + bottomPadding
        
        if value < fullDimPosition {
            return fullDimAlpha
        }
        
        if value > noDimPosition {
            return 0.0
        }
        return fullDimAlpha * 1 - ((value - fullDimPosition) / fullDimPosition)
    }
    
    // MARK: - Timer
    
    func startTimer() {
        timer?.invalidate()
        
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
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func loadAudio() {
        let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: songURL)
        } catch {
            preconditionFailure("Failure to load audio file: \(error)")
        }
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            updateViews()
            startTimer()
        } catch {
            print("Cannot play audio: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    
    // MARK: - Recording
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
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
    
    func startRecording() {
        do {
            try prepareAudioSession()
        } catch {
            print("Cannot record audio: \(error)")
            return
        }
        
        recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, format: format)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            updateViews()
            startTimer()
            
        } catch {
            preconditionFailure("The audio recorder could not be created with \(recordingURL!) and \(format)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
        cancelTimer()
    }
    
    //MARK: - IBACtions
    
    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        if isPlaying {
            pause()
        }
        audioPlayer?.currentTime = TimeInterval(sender.value)
        updateViews()
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        if isRecording {
            stopRecording()
        } else {
            requestPermissionOrStartRecording()
        }
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let context =  (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let sound = Sound(entity: Sound.entity(), insertInto: context)
            sound.name  = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
            if let recordingURL = self.recordingURL {
                sound.audioData = try? Data(contentsOf: recordingURL)
                try? context.save()
            }
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        hideCardAndGoBack()
    }
    
    
    @IBAction func dimmerViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideCardAndGoBack()
    }
    
    @IBAction func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
        let velocity = panRecognizer.velocity(in: self.view)
        let translation = panRecognizer.translation(in: self.view)
        
        switch panRecognizer.state {
        case .began:
            cardPanStartingTopConstant = cardViewTopConstraint.constant
            
        case .changed:
            if self.cardPanStartingTopConstant + translation.y > 400.0 {
                self.cardViewTopConstraint.constant = self.cardPanStartingTopConstant + translation.y
            }
            
            // change the dimmer view alpha based on how much user has dragged
            dimmerView.alpha = dimAlphaWithCardTopConstraint(value: self.cardViewTopConstraint.constant)
            
        case .ended:
            if velocity.y > 1500.0 {
                hideCardAndGoBack()
                return
            }
            
            if let safeAreaHeight = view?.window?.safeAreaLayoutGuide.layoutFrame.size.height,
                let bottomPadding = view?.window?.safeAreaInsets.bottom {
                
                if self.cardViewTopConstraint.constant < (safeAreaHeight + bottomPadding) * 0.75 {
                    showCard(atState: .expanded)
                } else if self.cardViewTopConstraint.constant < (safeAreaHeight) - 70 {
                    showCard(atState: .normal)
                } else {
                    hideCardAndGoBack()
                }
            }
            
        default:
            break
        }
    }
}

extension VoiceRecorderViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        cancelTimer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio player error: \(error)")
        }
    }
}


extension VoiceRecorderViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
        }
        audioRecorder = nil
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio recorder error: \(error)")
        }
    }
}

