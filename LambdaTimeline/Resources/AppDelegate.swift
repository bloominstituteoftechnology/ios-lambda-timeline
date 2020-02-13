//
//  AppDelegate.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let signIn = GIDSignIn.sharedInstance()
        signIn?.clientID = FirebaseApp.app()?.options.clientID
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let postsTabBarController = storyboard.instantiateViewController(withIdentifier: "PostsTabBarController") as? UITabBarController else { return false }
            guard let imageNavController = postsTabBarController.viewControllers?.first as? UINavigationController, let postsCollectionVC = imageNavController.viewControllers.first as? PostsCollectionViewController else { return false }
            guard let videoNavController = postsTabBarController.viewControllers?[1] as? UINavigationController, let videoPostsCollectionVC = videoNavController.viewControllers.first as? VideoPostsCollectionViewController else { return false }
            guard let mapViewController = postsTabBarController.viewControllers?.last as? MapViewController else { return false }
            
            let postController = PostController()
            videoPostsCollectionVC.postController = postController
            postsCollectionVC.postController = postController
            mapViewController.postController = postController
            
            window?.rootViewController = postsTabBarController
            window?.makeKeyAndVisible()
        }
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: [:])
    }
}

