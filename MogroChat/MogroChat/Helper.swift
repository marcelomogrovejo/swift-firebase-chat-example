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

                self.appDelegate.window?.rootViewController = self.getRootViewController(viewControllerIdentifier: "NavigationVC")
                
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
                
                if let email = googleUser?.email {
                    print(email)
                }
                
                if let displayName = googleUser?.displayName {
                    print(displayName)
                }
                
                self.appDelegate.window?.rootViewController = self.getRootViewController(viewControllerIdentifier: "NavigationVC")
            }
        })
    }
    
    func logOut() {
        let logInViewController = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
        appDelegate.window?.rootViewController = logInViewController
    }
    
}
