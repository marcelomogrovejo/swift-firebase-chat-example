//
//  Helper.swift
//  MogroChat
//
//  Created by Marcelo Mogrovejo on 5/22/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import Foundation
import Firebase

class Helper {
    
    static let helper = Helper()
    
    func anonymouslyLogIn() {
        
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser: FIRUser?, error: Error?) in
            if error == nil {
                print("user: \(anonymousUser!.uid)")
                
                // switch view by setting navigation controller as root view controller
                // Create a main storyboard instance
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                // From main storyboard instanctiate a navigation controller
                let navigationController = storyboard.instantiateViewController(withIdentifier: "NavitationVC") as! UINavigationController
                
                // Get the app delegate
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                // Set Navigation Controller as root view controller
                appDelegate.window?.rootViewController = navigationController
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
        
    }
    
    func googleLogIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavitationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController

    }
    
}
