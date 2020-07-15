//
//  CameraViewController.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/14/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet var cameraPreview: CameraPreviewView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var videoTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // MARK: - IBAction
    @IBAction func recordButtonPressed(_ sender: Any) {
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    // MARK: - Functions
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
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
