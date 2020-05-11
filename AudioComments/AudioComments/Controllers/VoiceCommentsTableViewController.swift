//
//  VoiceCommentsTableViewController.swift
//  AudioComments
//
//  Created by Joshua Rutkowski on 5/10/20.
//  Copyright © 2020 Josh Rutkowski. All rights reserved.
//

import UIKit
import AVFoundation


class VoiceCommentsTableViewController: UITableViewController {
    var sounds: [Sound] =  []
    var audioPlayer : AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getSound() {
      if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
        if let sound = ((try? context.fetch(Sound.fetchRequest()) as? [Sound]) as [Sound]??) {
          if let soundData = sound {
            sounds = soundData
            tableView.reloadData()
          }
        }
      }
    }
    
    override func viewWillAppear(_ animated: Bool) {
      getSound()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sounds.count
    }
 
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
       
       // Configure the cell...
       let sound = sounds[indexPath.row]
       if let soundRow = sound.name {
         cell.textLabel?.text = soundRow
       }
       return cell
     }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
          let sound = sounds[indexPath.row]
          context.delete(sound)
            do {
                try context.save()
                getSound()
            } catch {
                print("Error deleting audio recording: \(error)")
            }
        }
      }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let sound = sounds[indexPath.row]
      if let audioData = sound.audioData {
        audioPlayer = try? AVAudioPlayer(data: audioData)
        audioPlayer?.play()
      }
    }

    //MARK: - IBActions
    @IBAction func addVoiceCommentButtonTapped(_ sender: Any) {
        
        guard let vc = (storyboard?.instantiateViewController(withIdentifier: "VoiceRecorderViewController") as? VoiceRecorderViewController) else { assertionFailure("No view controller ID VoiceRecorderViewController  in storyboard")
            return
        }
        
        // Delays taking a snapshot of current view by 0.1 seconds to capture correct button state and sets the snapshot to backingImage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            // Include title and bar button items in snapshot
            vc.backingImage = self.navigationController?.view.asImage()
            
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        })
    }
}
