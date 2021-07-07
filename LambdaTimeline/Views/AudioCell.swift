
import UIKit

class AudioCell: UITableViewCell {
    
    static let reuseIdentifier = "audiocell"
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var timestampOutlet: UILabel!
    
    var audioURL: URL?
    var player: Player = Player()
    
    @IBAction func playAudioButton(_ sender: Any) {
        player.play(file: audioURL)
    }
    
}
