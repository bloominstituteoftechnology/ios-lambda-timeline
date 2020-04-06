//
//  SignInViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth


class SignInViewController: UIViewController {
    
    //MARK:- Properties
    
    private let signInWithGoogleButton : GIDSignInButton = {
        let button = GIDSignInButton()
        button.colorScheme = .dark
        button.style  = .wide
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
      //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        setUpSignInButton()
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
}

extension SignInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Error signing in with Google: \(error)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error signing in with Google: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let postsNavigationController = storyboard.instantiateViewController(withIdentifier: "PostsNavigationController")
                postsNavigationController.modalPresentationStyle = .fullScreen
                self.present(postsNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("User disconnected")
    }
    
  
    private func setUpSignInButton() {
        
        view.addSubview(signInWithGoogleButton)
        
        
        let buttonCenterXConstraint = signInWithGoogleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let buttonCenterYConstraint = signInWithGoogleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: 300)
        let buttonWidthConstraint = signInWithGoogleButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        
        view.addConstraints([buttonCenterXConstraint,
                             buttonCenterYConstraint,
                             buttonWidthConstraint])
    }
}
