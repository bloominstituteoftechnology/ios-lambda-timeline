//
//  AudioCommentTableViewController.swift
//  AudioComments
//
//  Created by Chris Dobek on 6/2/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentTableViewController: UITableViewController {
    
    var elements: [(String, URL)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("elements.count \(elements.count)")
        return elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioClipCell", for: indexPath) as? AudioClipTableViewCell else { return AudioClipTableViewCell() }
        
        // Configure the cell...
        cell.textLabel?.text = elements[indexPath.row].0
        cell.clip = elements[indexPath.row].1
        
        return cell
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AddAudioClip" {
            guard let vc = segue.destination as? RecordingViewController else {return}
            vc.delegate = self
        }
    }
}

