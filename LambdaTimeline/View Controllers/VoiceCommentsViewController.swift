//
//  VoiceCommentsViewController.swift
//  LambdaTimeline
//
//  Created by Michael on 3/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class VoiceCommentsViewController: UIViewController {

    var handleView = UIView()
    
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandelView()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setupHandelView() {
        handleView.layer.cornerRadius = 2.5
        handleView.backgroundColor = UIColor(r: 208, g: 207, b: 205)
        view.addSubview(handleView)
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.widthAnchor.constraint(equalToConstant: 37.5).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        handleView.alpha = 0
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
