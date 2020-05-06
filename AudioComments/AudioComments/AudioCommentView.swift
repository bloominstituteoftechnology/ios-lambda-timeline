//
//  AudioCommentView.swift
//  AudioComments
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class AudioCommentView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timelineSlider: UISlider!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    @IBOutlet weak var textField: UITextField!
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    //MARK: - Private Methods
    
    private func setup() {
        Bundle.main.loadNibNamed("AudioCommentView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
    }

}
