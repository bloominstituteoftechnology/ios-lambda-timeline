
import UIKit

class AudioCell: UITableViewCell {
    
    static let reuseIdentifier = "audiocell"
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var timestampOutlet: UILabel!
    
    @IBAction func playAudioButton(_ sender: Any) {
        //Player.play()
    }
    
}
