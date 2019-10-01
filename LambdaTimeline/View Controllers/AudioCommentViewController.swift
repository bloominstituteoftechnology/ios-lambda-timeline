//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Luqmaan Khan on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentViewController: UIViewController {

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func recordButtonTapped(_ sender: UIButton) {
    }
    @IBAction func playButtonTapped(_ sender: UIButton) {
    }
    @IBAction func createCommentButtonTapped(_ sender: UIButton) {
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
