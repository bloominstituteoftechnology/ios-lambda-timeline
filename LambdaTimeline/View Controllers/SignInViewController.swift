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

class SignInViewController: UIViewController {

    @IBOutlet weak var bypassSignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
//        signIn?.delegate = self
//        signIn?.uiDelegate = self
//        signIn?.signInSilently()
        
        setUpSignInButton()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            NSLog("Error signing in with Google: \(error)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                NSLog("Error signing in with Google: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let postsNavigationController = storyboard.instantiateViewController(withIdentifier: "PostsNavigationController")
                self.present(postsNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func bypassSegueTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postsNavigationController = storyboard.instantiateViewController(withIdentifier: "PostsNavigationController")
        self.present(postsNavigationController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("User disconnected")
    }
    
    func updateViews() {
        bypassSignInButton.layer.cornerRadius = 50
        bypassSignInButton.layer.borderWidth = 2.0
        bypassSignInButton.layer.backgroundColor = UIColor.systemBlue.cgColor
    }
    
    func setUpSignInButton() {
        
        let button = GIDSignInButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        
        
        let buttonCenterXConstraint = button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let buttonCenterYConstraint = button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let buttonWidthConstraint = button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        
        view.addConstraints([buttonCenterXConstraint,
                             buttonCenterYConstraint,
                             buttonWidthConstraint])
    }
}

//extension SignInViewController: GIDSignInDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//
//        if let error = error {
//          NSLog("Error signing in with Google: \(error)")
//          return
//        }
//
//        guard let authentication = user.authentication else { return }
//
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
//
//        Auth.auth().signIn(with: credential) { (authResult, error) in
//          if let error = error {
//            NSLog("Error signing in with Google: \(error)")
//            return
//          }
//
//          DispatchQueue.main.async {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let postsNavigationController = storyboard.instantiateViewController(withIdentifier: "PostsNavigationController")
//            self.present(postsNavigationController, animated: true, completion: nil)
//            }
//        }
//    }
//
//      func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        print("User disconnected")
//        }
//    }
//}
