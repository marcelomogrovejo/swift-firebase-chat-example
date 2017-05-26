//
//  Helper.swift
//  MogroChat
//
//  Created by Marcelo Mogrovejo on 5/22/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

class Helper {
    
    static let helper = Helper()
    
    // Create a main storyboard instance
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    // Get the app delegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func getRootViewController(viewControllerIdentifier: String) -> UINavigationController {
        return self.storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as! UINavigationController
    }
    
    func anonymouslyLogIn() {
        
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser: FIRUser?, error: Error?) in
            if error == nil {
                print("user: \(anonymousUser!.uid)")

                if let user = anonymousUser {
                    let newUser = FIRDatabase.database().reference().child("users").child(user.uid)
                    newUser.setValue(["displayName": "anonymous", "id": user.uid, "photoUrl": ""])
                }
                
                self.switchToNavigationViewController()
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
        
    }
    
    func googleLogIn(authentication: GIDAuthentication) {
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (googleUser: FIRUser?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                if let user = googleUser {
                    let newUser = FIRDatabase.database().reference().child("users").child(user.uid)
                    newUser.setValue(["displayName": "\(user.displayName!)", "id": "\(user.uid)", "photoUrl": "\(user.photoURL!)"])
                }
                
                self.switchToNavigationViewController()
            }
        })
    }
    
    func switchToNavigationViewController() {
        self.appDelegate.window?.rootViewController = self.getRootViewController(viewControllerIdentifier: "NavigationVC")
    }
    
    func logOut() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        let logInViewController = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
        appDelegate.window?.rootViewController = logInViewController
    }
    
}
