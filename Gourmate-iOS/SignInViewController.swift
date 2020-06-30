//
//  SignInViewController.swift
//  Gourmate-iOS
//
//  Created by Sriram Hariharan on 6/13/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        googleSignInButton.style = GIDSignInButtonStyle.wide
        // Change all screens to dark mode
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        // Do any additional setup after+++ loading the view.
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let auth = user.authentication else { return }
            let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
            Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Login Successful")
                let user: GIDGoogleUser = GIDSignIn.sharedInstance()!.currentUser
                let fullName = user.profile.name
                let email = user.profile.email
                var userDP = URL(string: "")
                if user.profile.hasImage {
                    userDP = user.profile.imageURL(withDimension: 200)
                }
                print("\(fullName) \(email) \(userDP)")
                
                self.performSegue(withIdentifier: "newUserSegue", sender: nil)
                // now we have the user objects here
            }
        }
    }
}

