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

var curUser:NSManagedObject = NSManagedObject()

class SignInViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        googleSignInButton.style = GIDSignInButtonStyle.wide
        // Change all screens to dark mode
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        ref = Database.database().reference()
        
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
                let email = user.profile.email
                
                if let userID = user.userID  {
                    self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.hasChild("\(userID)"){
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let context = appDelegate.persistentContainer.viewContext
                            
                            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                            request.returnsObjectsAsFaults = false
                            let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
                            let newUser = NSManagedObject(entity: entity!, insertInto: context)
                            newUser.setValue( GIDSignIn.sharedInstance()!.currentUser.profile.email, forKey: "email")
                            newUser.setValue(curUserNotif, forKey: "notifications")
                            newUser.setValue(true, forKey: "darkMode")
                            curUser = newUser // Save current user globally

                            do {
                                try context.save()
                            } catch {
                                print("Failed saving")
                            }
                            self.performSegue(withIdentifier: "existingUserSegue", sender: nil)
                        } else{
                            self.performSegue(withIdentifier: "newUserSegue", sender: nil)
                        }
                    }
                    )}
            }
        }
    }
}

