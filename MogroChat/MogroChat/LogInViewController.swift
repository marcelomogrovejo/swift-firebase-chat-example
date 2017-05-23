//
//  LogInViewController.swift
//  MogroChat
//
//  Created by Marcelo Mogrovejo on 5/22/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import GoogleSignIn

class LogInViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    // MARK: Outlets
    
    @IBOutlet weak var anonymouslyLogInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        anonymouslyLogInButton.layer.borderWidth = 2.0
        anonymouslyLogInButton.layer.borderColor = UIColor.white.cgColor
        
        GIDSignIn.sharedInstance().clientID = "1037327570432-4mo9378pmrp0gonf66rs2r45q5vmesta.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action methods

    @IBAction func anonymouslyLogIn(_ sender: Any) {
        Helper.helper.anonymouslyLogIn()
    }
  
    @IBAction func googleLogIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }

    // MARK: GIDSignInDelegate methods
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            
            print("Access token: \(user.authentication)")
            
            Helper.helper.googleLogIn(authentication: user.authentication)
        } else {
            print("\(error.localizedDescription)")
        }
    }
        
}
