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

class SignInViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signIn = GIDSignIn.sharedInstance()
        
        signIn?.delegate = self
        signIn?.uiDelegate = self
        signIn?.signInSilently()
        
        setUpSignInButton()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            NSLog("Error signing in with Google: \(error)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                NSLog("Error signing in with Google: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let postsTabBarController = storyboard.instantiateViewController(withIdentifier: "PostsTabBarController") as? UITabBarController else { return }
                guard let imageNavController = postsTabBarController.viewControllers?.first as? UINavigationController, let postsCollectionVC = imageNavController.viewControllers.first as? PostsCollectionViewController else { return }
                guard let videoNavController = postsTabBarController.viewControllers?[1] as? UINavigationController, let videoPostsCollectionVC = videoNavController.viewControllers.first as? VideoPostsCollectionViewController else { return }
                guard let mapViewController = postsTabBarController.viewControllers?.last as? MapViewController else { return }
                
                let postController = PostController()
                videoPostsCollectionVC.postController = postController
                postsCollectionVC.postController = postController
                mapViewController.postController = postController
                
                self.present(postsTabBarController, animated: true, completion: nil)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("User disconnected")
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
