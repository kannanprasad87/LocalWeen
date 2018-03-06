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
        GIDSignIn.sharedInstance().uiDelegate = self
        checkIfUserIsSignedIn()
    }//viewDidLoad
    
    //creating the Google sign in button
    fileprivate func configureGoogleSignInButton() {
        
            let googleSignInButton = GIDSignInButton()
            view.addSubview(googleSignInButton)
        
    }//configureGoogleSignInButton
    
    private func checkIfUserIsSignedIn() {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                print("User has authorization \(String(describing: user?.displayName))")
                GIDSignIn.sharedInstance().signInSilently()
                self.goToMap()
            } else {
                print("User is not authorized present Google Sign in button")
                self.configureGoogleSignInButton()
            }
        }
    }
    
    func goToMap(){
        performSegue(withIdentifier: "toMap", sender: self)
    }//goToMap
    
    
    
}//WelcomeViewController

