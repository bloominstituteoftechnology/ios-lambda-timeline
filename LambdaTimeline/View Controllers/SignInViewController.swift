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
import AuthenticationServices
import CryptoKit
import FBSDKCoreKit
import FBSDKLoginKit

extension SignInViewController: LoginButtonDelegate {

    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                print(error)
                return
            }
            // if success
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let postsNavigationController = storyboard.instantiateViewController(withIdentifier: "PostsNavigationController")
                postsNavigationController.modalPresentationStyle = .fullScreen
                self.present(postsNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
class SignInViewController: UIViewController {
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
   
    
    
    //MARK:- Properties
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    private let signInWithGoogleButton : GIDSignInButton = {
        let button = GIDSignInButton()
        button.colorScheme = .dark
        button.style  = .wide
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signInWithAppleButton: ASAuthorizationAppleIDButton = {
       let button = ASAuthorizationAppleIDButton()
        button.cornerRadius = .pi
        button.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
  
    @objc func didTapAppleButton() {
       let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // Generate nonce for validation after authentication successful
        self.currentNonce = randomNonceString()
        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = sha256(currentNonce!)

        // Present Apple authorization form
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
    
    private let facebookButton : FBLoginButton = {
       let button = FBLoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tooltipColorStyle = .neutralGray
        button.tooltipBehavior = .automatic
        
        return button
    }()
    
      //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
      
            facebookButton.delegate = self
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
            //success
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
        view.addSubview(signInWithAppleButton)
        view.addSubview(facebookButton)
        
        let buttonCenterXConstraint = signInWithGoogleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let buttonCenterYConstraint = signInWithGoogleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: 300)
        let buttonWidthConstraint = signInWithGoogleButton.widthAnchor.constraint(equalTo: signInWithAppleButton.widthAnchor)
        
        view.addConstraints([buttonCenterXConstraint,
                             buttonCenterYConstraint,
                             buttonWidthConstraint,
                             
        
        ])
        
        NSLayoutConstraint.activate([
          
            signInWithAppleButton.bottomAnchor.constraint(equalTo: signInWithGoogleButton.topAnchor,constant: -20),
            signInWithAppleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            facebookButton.bottomAnchor.constraint(equalTo: signInWithAppleButton.topAnchor,constant: -20),
            facebookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        
          // Save authorised user ID for future reference
          UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
          
          // Retrieve the secure nonce generated during Apple sign in
          guard let nonce = self.currentNonce else {
              fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }

          // Retrieve Apple identity token
          guard let appleIDToken = appleIDCredential.identityToken else {
              print("Failed to fetch identity token")
              return
          }

          // Convert Apple identity token to string
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
              print("Failed to decode identity token")
              return
          }

          // Initialize a Firebase credential using secure nonce and Apple identity token
          let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                            idToken: idTokenString,
                                                            rawNonce: nonce)
              
          // Sign in with Firebase
          Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
              
              if let error = error {
                  print(error.localizedDescription)
                  return
              }
              
              // Mak a request to set user's display name on Firebase
              let changeRequest = authResult?.user.createProfileChangeRequest()
              changeRequest?.displayName = appleIDCredential.fullName?.givenName
              changeRequest?.commitChanges(completion: { (error) in

                  if let error = error {
                      print(error.localizedDescription)
                  } else {
                    DispatchQueue.main.async {
                                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                 let postsNavigationController = storyboard.instantiateViewController(withIdentifier: "PostsNavigationController")
                                 postsNavigationController.modalPresentationStyle = .fullScreen
                                 self.present(postsNavigationController, animated: true, completion: nil)
                             }
                      print("Updated display name: \(Auth.auth().currentUser!.displayName!)")
                  }
              })
          }
          
      }
  }
}
extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
}
