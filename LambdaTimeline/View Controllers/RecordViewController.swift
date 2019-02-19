
import UIKit

class RecordViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    
    
    
    
    
    @IBAction func tappedRecordButton(_ sender: Any) {
    }
    
    @IBAction func tappedPlayButton(_ sender: Any) {
    }
    
    @IBAction func addCommentButton(_ sender: Any) {
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

