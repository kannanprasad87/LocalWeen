//
//  WeclomeViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuth


fileprivate enum Defaults {
    static let buttonTopAnchor: CGFloat = 70.0
    static let buttonLeadingAnchor: CGFloat = 32.0
    static let buttonTrailingAnchor: CGFloat = 32.0
    static let facebookLoginButtonHeight: CGFloat = 40.0
}

class WelcomeViewController: UIViewController {
    
    fileprivate let fbLoginButton = FBSDKLoginButton()
    fileprivate let googleSignInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetups()
    }
    
    // MARK: - Initial UI Setups
    fileprivate func initialUISetups() {
        facebookButtonSetup()
        googleButtonSetup()
    }
    
    // MARK: Facebook Sign In Button Setup
    
    fileprivate func facebookButtonSetup() {
        // Facebook Login Button Setups
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
        if let facebookButtonHeightConstraint = fbLoginButton.constraints.first(where: { $0.firstAttribute == .height }) {
            fbLoginButton.removeConstraint(facebookButtonHeightConstraint)
        }
        // Add Constraints to fb login button
        fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        fbLoginButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Defaults.buttonTopAnchor).isActive = true
        fbLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.buttonLeadingAnchor).isActive = true
        fbLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.buttonTrailingAnchor).isActive = true
        fbLoginButton.heightAnchor.constraint(equalToConstant: Defaults.facebookLoginButtonHeight).isActive = true
    }
    
    // MARK: Google Sign In Button Setup
    
    fileprivate func googleButtonSetup() {
        // Google Sign In Button Setups
        view.addSubview(googleSignInButton)
        googleSignInButton.style = .wide
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        // Add Constraints to Google Sign In Button
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.topAnchor.constraint(equalTo: fbLoginButton.topAnchor, constant: Defaults.buttonTopAnchor).isActive = true
        googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.buttonLeadingAnchor).isActive = true
        googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.buttonTrailingAnchor).isActive = true
    }
    
    
    // Basic Alert View
    fileprivate func showAlert(withTitle title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func goToMap(){
        performSegue(withIdentifier: "toMap", sender: self)
    }//goToMap
    
}//fetchUserProfileData

// MARK: - Facebook SDK Button Delegates
extension WelcomeViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith loginResult: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            showAlert(withTitle: "Error", message: error as! String)
        } else if loginResult.isCancelled {
            
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    self.showAlert(withTitle: "Error", message: error as! String)
                    return
                }//error
                //Successful log in
             
                let params = ["fields": "email, first_name, last_name, picture"]
                FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { connection, graphResult, error in
                    if let error = error {
                        print("Error getting FB social info \(String(describing: error))")
                        return
                    }//error
                    let fields = graphResult as? [String:Any]
                    
                    if FBSDKAccessToken.current().hasGranted("email"){
                        social.usrEmail = fields!["email"] as! String
                    }//email
                 
                    if FBSDKAccessToken.current().hasGranted("first_name") {
                        social.usrGivenName = fields!["first_name"] as! String
                    }//first_name
                    
                    if FBSDKAccessToken.current().hasGranted("picture") {
                        let url = fields!["picture"] as! URL
                        print("url \(String(describing: url))")
                        let session = URLSession.shared
                        session.dataTask(with: url) { (data, response, error) in
                            if let error = error {
                                print("Error getting data from URL: \(error)")
                            }//error
                            if let data = data {
                                social.usrProfilePhoto  = UIImage(data: data)!
                            }//data
                        } .resume() //session.dataTask
                    }//FBSDKAccessToken
                }//FBSDKGraphRequest
            ) //completion handler //FBSDKGraphRequest
        }//Auth
    }//else
        self.goToMap()
}//loginButton
                  
  
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        showAlert(withTitle: "Success", message: "Successfully Logged out")
    }
}

// MARK: - Google Sign In Delgates
extension WelcomeViewController: GIDSignInUIDelegate {
    
}

extension WelcomeViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            print((String(describing: error) ))
        }
        
        //MARK: GET GOOGLE PROFILE DATA HERE
        
        goToMap()
    }
}


