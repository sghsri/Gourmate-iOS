//
//  SignInViewController.swift
//  Gourmate-iOS
//
//  Created by Sriram Hariharan on 6/13/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import CoreData

var curUser:NSManagedObject!
var curUserEmail:String!

class SignInViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        googleSignInButton.style = GIDSignInButtonStyle.wide // Google sign in
        
        // Change all screens to "light mode"
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
        
        // Set up Firebase Google sign in
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        ref = Database.database().reference()
        
    }
    
    // Google Sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let auth = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            // Error for sign in
            if let error = error {
                print(error.localizedDescription)
            // Login was successful
            } else {
                print("Login Successful")
                
                // Get user value and email
                let user: GIDGoogleUser = GIDSignIn.sharedInstance()!.currentUser
                let email = user.profile.email
                
                // Gather all data for user and sign in
                if let userID = user.userID  {
                    self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                        // Existing user in Firebase
                        if snapshot.hasChild("\(userID)"){
                            
                            // Find existing user in Core Data
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let context = appDelegate.persistentContainer.viewContext
                            
                            // Get users in Core Data
                            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                            var fetchedResults: [NSManagedObject]? = nil
                            do {
                                try fetchedResults = context.fetch(request) as? [NSManagedObject]
                            } catch {
                                // if an error occurs
                                let nserror = error as NSError
                                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                                abort()
                            }
                            
                            var found = false
                            // Search through core data for current user
                            for user in fetchedResults! {
                                if let curEmail = user.value(forKey:"email"), curEmail as? String == email {
                                    
                                    // Found user in Core Data
                                    curUser = user // Save current user globally
                                    curUserEmail = email
                                    found = true
                                    
                                    // Set dark mode if they set it previously
                                    let darkMode = user.value(forKey:"darkMode")
                                    UIApplication.shared.windows.forEach { window in
                                        window.overrideUserInterfaceStyle = (darkMode as! Bool) ? .dark : .light
                                    }
                                    
                                }
                            }
                            
                            // User is not in Core Data - create new user (the case where someone logs in from a different phone
                            // Possible addition: store preferences in Firebase and create new user based on those preferences
                            if !found {
                                let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
                                let newUser = NSManagedObject(entity: entity!, insertInto: context)
                            newUser.setValue(GIDSignIn.sharedInstance()!.currentUser.profile.email, forKey: "email")
                                newUser.setValue(false, forKey: "location")
                                newUser.setValue(false, forKey: "darkMode")
                                curUser = newUser // Save current user globally
                                curUserEmail = email
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("Failed saving")
                                }
                            }
                            
                            // Go to Group Screen
                            self.performSegue(withIdentifier: "existingUserSegue", sender: nil)
                        // New User
                        } else {
                            
                            // Go to New User Screen
                            self.performSegue(withIdentifier: "newUserSegue", sender: nil)
                        }
                    })
                }
            }
        }
    }
}

