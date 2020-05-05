//
//  ViewController.swift
//  AudioMessageFeatures
//
//  Created by Ezra Black on 5/5/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit

struct CellData {
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
}

class MessageViewController: UIViewController {
    
    //MARK: Properties-
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [CellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableViewData = [CellData(opened: false, title: "Test Cell", sectionData: ["", "Recorded: Mar 4", "Sender: ", "Reply: "]),
                         CellData(opened: false, title: "Test Cell2", sectionData: ["", "Recorded: Apr 9", "Sender: ", "Reply: "]),
                         CellData(opened: false, title: "Test Cell3", sectionData: ["", "Recorded: May 3", "Sender: ", "Reply: "])
        ]
    }
}
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count
        } else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") else { return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].title
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") else { return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[indexPath.row]
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableViewData[indexPath.section].opened == true {
            tableViewData[indexPath.section].opened = false
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        } else {
            tableViewData[indexPath.section].opened = true
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        }
    }
}

