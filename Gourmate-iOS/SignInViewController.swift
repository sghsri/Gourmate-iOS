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
import CoreData

var curUser:NSManagedObject = NSManagedObject()

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
                
                
                // Store email in Core Data
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                request.returnsObjectsAsFaults = false
                var found = false
                
                do {
                    let result = try context.fetch(request)
                    
                    // Search through current users
                    for user in result as! [NSManagedObject] {

                        // Already have this user - fetch current data
                        if let curEmail = user.value(forKey:"email"), (email == curEmail as? String){
                            curUser = user // Save current user globally
                            found = true
                            self.performSegue(withIdentifier: "existingUserSegue", sender: nil)
                        }
                    }
                    
                } catch {
                    
                    print("Failed")
                }

                // User wasn't found in Core Data - add user to Core Data
                if !found {
                    let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
                    let newUser = NSManagedObject(entity: entity!, insertInto: context)
                    newUser.setValue(email, forKey: "email")
                    
                    do {
                        try context.save()
                        } catch {
                        print("Failed saving")
                    }
                    
                    curUser = newUser // Save current user globally

                    self.performSegue(withIdentifier: "newUserSegue", sender: nil)
                }
            }
        }
    }
}

