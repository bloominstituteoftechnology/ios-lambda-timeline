//
//  FilterChooserViewController.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreImage

protocol FilterChooserViewControllerDelegate: AnyObject {
    func filterChooserViewController(_ viewController: FilterChooserViewController, didChooseFilter filter: CIFilter?)
}

class FilterChooserViewController: UITableViewController {
    
    weak var delegate: FilterChooserViewControllerDelegate?
    
    private let categories = [
        kCICategoryBuiltIn,
        kCICategoryColorAdjustment,
        kCICategoryColorEffect,
        kCICategoryDistortionEffect,
        kCICategoryGeometryAdjustment,
        kCICategoryCompositeOperation,
        kCICategoryHalftoneEffect,
        kCICategoryTransition,
        kCICategoryTileEffect,
        kCICategoryGenerator,
        kCICategoryReduction,
        kCICategoryGradient,
        kCICategoryStylize,
        kCICategorySharpen,
        kCICategoryBlur,
        kCICategoryVideo,
        kCICategoryStillImage,
        kCICategoryInterlaced,
        kCICategoryNonSquarePixels,
        kCICategoryHighDynamicRange
    ]
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.filterChooserViewController(self, didChooseFilter: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CIFilter.filterNames(inCategory: categories[section]).count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let name = categories[section]
        return CIFilter.localizedName(forCategory: name)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        
        let category = categories[indexPath.section]
        let names = CIFilter.filterNames(inCategory: category)
        let name = CIFilter.localizedName(forCategory: names[indexPath.row])
        
        cell.textLabel?.text = name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = categories[indexPath.section]
        let names = CIFilter.filterNames(inCategory: category)
        let name = names[indexPath.row]
        
        let filter = CIFilter(name: name)
        
        delegate?.filterChooserViewController(self, didChooseFilter: filter)
    }
    
}
