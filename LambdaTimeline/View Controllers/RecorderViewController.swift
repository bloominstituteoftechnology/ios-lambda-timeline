//
//  RecorderViewController.swift
//  LambdaTimeline
//
//  Created by Jonathan Ferrer on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class RecorderViewController: UIViewController {


    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func recordButtonPressed(_ sender: Any) {

    }

    @IBAction func doneButtonPressed(_ sender: Any) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    



    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var doneButton: UIButton!

}
