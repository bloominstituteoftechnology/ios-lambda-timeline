//
//  AudioPlayerViewController.swift
//  AudioComments
//
//  Created by Bhawnish Kumar on 6/2/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

class AudioPlayerViewController: UIViewController {

    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var audioSlider: UISlider!
    @IBOutlet private var recordingButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
    }
    @IBAction func togglePlayback(_ sender: Any) {
          
        }
        
        @IBAction func updateCurrentTime(_ sender: UISlider) {
            
        }
        
        @IBAction func toggleRecording(_ sender: Any) {
       
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
