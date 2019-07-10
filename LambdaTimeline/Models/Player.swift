//
//  Player.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation
protocol PlayerDelegate: AnyObject { // because we subclass NSObject we have to conform to any object here
    func playerDidChangeState(player: Player)
}

class Player: NSObject { //has to be of nsobject so that we can conform to a protocol
    
    //need the actual thing/object to access its functionality
    private var audioPlayer: AVAudioPlayer? //So that we can create it at a later time
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    weak var delegate: PlayerDelegate?
    
    
    //player needs a url to play
    override init(){
        super.init()
    }
    
    //MARK: Functionality of the player
    
    //playing
    func play(){
        audioPlayer?.play()
        //notifiy delegate
        notifyDelegate()
    }
 
    //pausing
    func pause(){
        audioPlayer?.pause()
        //notify delegate
        notifyDelegate()
    }
    
    func playPause(){
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    //create a function to notify the delegate
    func notifyDelegate(){
        delegate?.playerDidChangeState(player: self)
    }
    
}
