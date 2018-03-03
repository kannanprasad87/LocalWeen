//
//  WeclomeViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import GoogleSignIn
import Firebase
class WelcomeViewController: UIViewController, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGoogleSignInButton()
    }
    
    //creating the Google sign in button
    fileprivate func configureGoogleSignInButton() {
        let googleSignInButton = GIDSignInButton()
        view.addSubview(googleSignInButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
}//WelcomeViewController

