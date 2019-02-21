//
//  ImagePostTableViewCell.swift
//  LambdaTimeline
//
//  Created by Sergey Osipyan on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class ImagePostTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       
    }

    
    
    var recordFile: URL?
    private let player = Player()
    private let recorder = Recorder()
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var play: UIButton!
   
    @IBAction func playAction(_ sender: Any) {
        player.playPause(song: recordFile)
    }
    
    
}
