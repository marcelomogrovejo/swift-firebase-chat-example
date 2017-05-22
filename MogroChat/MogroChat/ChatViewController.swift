//
//  ChatViewController.swift
//  MogroChat
//
//  Created by Marcelo Mogrovejo on 5/22/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Action methods
    
    @IBAction func logOut(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logInViewController = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = logInViewController

    }
   
}
