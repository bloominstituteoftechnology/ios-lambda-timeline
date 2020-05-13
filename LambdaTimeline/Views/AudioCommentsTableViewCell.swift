//
//  AudioCommentsTableViewCell.swift
//  LambdaTimeline
//
//  Created by Sal B Amer on 5/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol PlayCommentsAudioDelegate: AnyObject {
  func playAudio(for url: URL)
}

class AudioCommentsTableViewCell: UITableViewCell {
  
  //Mark: Outlets
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var playBtn: UIButton!
  
  
  var delegate: PlayCommentsAudioDelegate?
  var comment: Comment? {
    didSet {
      updateViews()
    }
  }
  
  private func updateViews() {
    guard let comment = comment else { return }
    nameLabel.text = comment.author.displayName
    
  }
  
 
  
  //MARK: Actions
  @IBAction func playBtnWasPressed(_ sender: UIButton) {
    guard let comment = comment,
      let url = comment.audioURL else { return }
      delegate?.playAudio(for: url)
  }
  
}
