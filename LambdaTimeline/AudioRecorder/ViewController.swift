
import UIKit

class ViewController: UIViewController, PlayerDelegate, RecorderDelegate {

    
   
    let imageDetail = ImagePostDetailTableViewController()
    let imagePostTableViewCell = ImagePostTableViewCell()
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeRemaining: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBAction func cancel(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
   
    @IBAction func save(_ sender: Any) {
        //self.postController.addAudioComment(with: recorder.currentFile!, to: post)
        
        imagePostTableViewCell.recordFile = recorder.currentFile
        imageDetail.recordFile = recorder.currentFile
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = .pad
        f.allowedUnits = [.minute, .second]
        return f
    }()
    
     let player = Player()
     let recorder = Recorder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fontSize = UIFont.systemFontSize
//        let font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
//
//        timeLabel.font = font
//        timeRemaining.font = font
        
        player.delegate = self
        recorder.delegate = self
    }


    @IBAction func tappedPlayButton(_ sender: Any) {
        // returns either the song if there is nothing recorded, or the most recent URL I have recorded
        player.playPause(song: recorder.currentFile)
    }
    
    @IBAction func tappedRecordButton(_ sender: Any) {
        recorder.toggleRecording()
    }
    
    func playerDidChangeState(_ player: Player) {
        updateViews()
    }
    
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    
    // I want a single method to use to update everything at once
    private func updateViews() {
        let isPlaying = player.isPlaying
        playButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        
        let isRecording = recorder.isRecording
        recordButton.setTitle(isRecording ? "Stop" : "Record", for: .normal)
        
        let elapsedTime = player.elapsedTime
        timeLabel.text = timeFormatter.string(from: player.elapsedTime)
        
        timeRemaining.text = timeFormatter.string(from: player.remainingTime)
        
        timerSlider.minimumValue = 0
        timerSlider.maximumValue = Float(player.totalTime)
        timerSlider.value = Float(player.elapsedTime)
    }
    

    
    
    
}

