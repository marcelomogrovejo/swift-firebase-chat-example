//
//  LogInViewController.swift
//  GoChat
//
//  Created by The Zero2Launch Team on 6/25/16.
//  Copyright © 2016 Zero2Launch. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
class LogInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var anonymousButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // anonymousButton:
        // Set boder color and width
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        GIDSignIn.sharedInstance().clientID = "582110307949-eo45grlveoeshogdp696n4o8jsklfus7.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(FIRAuth.auth()?.currentUser)
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            print("test3")
            if user != nil {
                print(user)
                Helper.helper.switchToNavigationViewController()
            } else {
                print("Unauthorized")
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAnonymouslyDidTapped(_ sender: AnyObject) {
        print("login anonymously did tapped")
        // Anonymously log users in
        // switch view by setting navigation controller as root view controller
        Helper.helper.loginAnonymously()
    }

    @IBAction func googleLoginDidTapped(_ sender: AnyObject) {
        print("google login did tapped")
        GIDSignIn.sharedInstance().signIn()
       
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        Helper.helper.logInWithGoogle(user.authentication)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
