//
//  ViewController.swift
//  AudioMessageFeatures
//
//  Created by Ezra Black on 5/5/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    //MARK: Properties-
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }


}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

