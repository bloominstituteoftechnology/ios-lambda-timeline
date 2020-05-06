//
//  ThumbnailsCollectionViewController.swift
//  iosVideo
//
//  Created by Karen Rodriguez on 5/6/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import AVFoundation

class ThumbnailsCollectionViewController: UICollectionViewController {

    // Confusing name I know I'm sorry :( but this is a custom class
    let files = FilesController()
    var urls: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
//
//        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateThumbnails()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return urls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoThumbnailIdentifier", for: indexPath)
    
        // Configure the cell
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    // MARK: - Methods

    private func populateThumbnails() {
        urls = files.fetchAllVideos()
    }


    // MARK: - Video Camera Permission
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .notDetermined: // first time we've requested access
            requestPermission()
        case .restricted: // parental controls prevent user from using the camera / microphone
            fatalError("Tell user they need to request permission from parent (UI)")
        case .denied:
            fatalError("Tell user to enable in Settings: Popup from Audio to do this, or use a custom view")
        case .authorized:
            showCamera()
        default:
            fatalError("Handle new  case for authorization")
        }
    }

    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                fatalError("Tell user to enable in Settings: Popup from Audio to do this, or use a custom view")
            }
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }

    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }

    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        requestPermissionAndShowCamera()
    }

}
