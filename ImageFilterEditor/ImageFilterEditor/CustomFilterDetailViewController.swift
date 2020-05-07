//
//  CustomFilterDetailViewController.swift
//  ImageFilterEditor
//
//  Created by Joshua Rutkowski on 5/6/20.
//  Copyright © 2020 Josh Rutkowski. All rights reserved.
//

import UIKit

class CustomFilterDetailViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var customFilterImageView: UIImageView!
    @IBOutlet weak var brightnessSliderControl: UISlider!
    @IBOutlet weak var saturationSliderControl: UISlider!
    @IBOutlet weak var contrastSliderControl: UISlider!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - IBActions
    
    @IBAction func saveButtonClicked(_ sender: Any) {
    }
    
    @IBAction func brightnessChanged(_ sender: Any) {
    }
    
    @IBAction func saturationtChanged(_ sender: Any) {
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
    }
    
    
}
