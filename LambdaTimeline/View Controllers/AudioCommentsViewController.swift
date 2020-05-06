//
//  AudioCommentsViewController.swift
//  LambdaTimeline
//
//  Created by Lydia Zhang on 5/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentsViewController: UIViewController {
    var views = UIView()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func setupView(){
        view.addSubview(views)
        views.translatesAutoresizingMaskIntoConstraints  = false
        views.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        views.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        views.widthAnchor.constraint(equalToConstant: 40).isActive = true
        views.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
    }
}
