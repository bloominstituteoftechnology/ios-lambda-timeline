//
//  AudioRecordingViewController.swift
//  LambdaTimeline
//
//  Created by Nick Nguyen on 4/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation




class AudioRecordingViewController: UIViewController
    
{

//MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(musicView)
        view.addSubview(playButton)
        view.addSubview(browseFileButton)
        view.addSubview(recordButton)
        view.addSubview(horizontalStackView)
        
        horizontalStackView.addArrangedSubview(playButton)
        horizontalStackView.addArrangedSubview(browseFileButton)
        horizontalStackView.addArrangedSubview(recordButton)
        
        setUpConstraintForMusicView()
        layoutStackView()
        
        
        setUpNavigationItem()
    }
    
    private func layoutStackView() {
        NSLayoutConstraint.activate([
        horizontalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -50),
        horizontalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        horizontalStackView.widthAnchor.constraint(equalToConstant: 300),
        horizontalStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
      
    }
    
    
    private let musicView: UIImageView = {
        let image = UIImage(systemName: "music.note")?.withTintColor(.black)
       let view = UIImageView(image: image )
        view.tintColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = view.frame.height / 2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 5
        return view
    }()
    
    private let playButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    @objc func handlePlay() {
        print("play")
    }
    
    
    private let browseFileButton : UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "folder.fill"), for: .normal)
        button.backgroundColor = .link
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleBrowse), for: .touchUpInside)
        return button
    }()
    
    private let recordButton: UIButton = {
       let button =  UIButton()
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.backgroundColor = .red
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRecord), for: .touchUpInside)
        
        
        return button
    }()
    @objc func handleRecord() {
        print("recording")
    }
    
    @objc func handleBrowse() {
        print("browsing...")
    }
    
    private let horizontalStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        return stackView
    }()
    
    private func setUpNavigationItem() {
      
     
        navigationItem.title = "Audio Comment"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .done, target: self, action: #selector(handleDone))
        view.backgroundColor = .white
    }
    
    private func setUpConstraintForMusicView() {
        NSLayoutConstraint.activate([
                 musicView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 musicView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -100),
                 musicView.widthAnchor.constraint(equalToConstant: 200),
                 musicView.heightAnchor.constraint(equalToConstant: 200)
             ])
    }
    
    @objc func handleDone() {
        print("Pick music success")
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    

}
