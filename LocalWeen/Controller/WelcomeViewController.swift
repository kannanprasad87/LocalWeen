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
import SwiftyBeaver


fileprivate enum Defaults {
    static let buttonTopAnchor: CGFloat = 70.0
    static let buttonLeadingAnchor: CGFloat = 32.0
    static let buttonTrailingAnchor: CGFloat = 32.0
    static let facebookLoginButtonHeight: CGFloat = 40.0
}

class WelcomeViewController: UIViewController {
    
    fileprivate let fbLoginButton = FBSDKLoginButton()
    fileprivate let googleSignInButton = GIDSignInButton()
    lazy var dbHandler:DBHandler = DBHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //hide the back button of navigation view controller, as it is not needed here
        //Handles an edge case where user CANCELED sign in and got to the welcome screen again
        self.navigationItem.hidesBackButton = true
        
        //if user already logged in to FB, go to map
        if FBSDKAccessToken.current() != nil{
            SwiftyBeaver.verbose("FBSDKAccessToken.current() != nil, goToMap")
            goToMap()
        }
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
        fbLoginButton.readPermissions = ["email","public_profile"]
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
            showAlert(withTitle: "Error", message: error.localizedDescription)
            SwiftyBeaver.error("WelcomeViewController: FBSDKLoginButtonDelegate - loginButton")
            SwiftyBeaver.error("Error on Facebook login \(String(describing: error.localizedDescription))")
        } else if loginResult.isCancelled {
            SwiftyBeaver.verbose("loginResult.isCancelled")
            return
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    self.showAlert(withTitle: "Error", message: error as! String)
                    SwiftyBeaver.error("func loginButton() for Facebook")
                    SwiftyBeaver.error("Auth.auth().signIn Error authorizing with Firebase")
                    SwiftyBeaver.error(error as! String)
                    return
                }//error
                //Successful log in
             
                SwiftyBeaver.verbose("Auth.auth().signIn Successful Firebase Auth")
                
                let params = ["fields": "email, first_name, last_name, picture"]
                FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { connection, graphResult, error in
                    if let error = error {
                        SwiftyBeaver.error("FBSDKGraphRequest Error getting FB social info \(String(describing: error))")
                        return
                    }//error
                    let fields = graphResult as? [String:Any]
                    
                    SwiftyBeaver.verbose("FBSDKGraphRequest graphResults")
                    SwiftyBeaver.verbose("\(String(describing: fields))")
                    
                    guard let email = fields!["email"] else {
                        SwiftyBeaver.warning("FBSDKGraphRequest can't get email")
                        return
                    }
                    
                    social.usrEmail = email as! String
                    SwiftyBeaver.verbose("FBSDKGraphRequest got email \(String(describing: email))")
                    
                    guard let firstName = fields!["first_name"] else {
                        SwiftyBeaver.warning("FBSDKGraphRequest can't get first_name")
                        return
                    }
                    social.usrGivenName = firstName as! String
                    SwiftyBeaver.verbose("FBSDKGraphRequest got first_name \(String(describing: firstName))")
                    
                    
                   /*********
                     FOR THE MOMENT, FORGET ABOUT THE PHOTO!
 ************/
                    
                }//FBSDKGraphRequest
            ) //Graph completion handler //FBSDKGraphRequest
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
        SwiftyBeaver.debug("WelcomeViewController: GIDSignInDelegate - sign")
        
        if (error) != nil {
            SwiftyBeaver.error("Either the user already signed out or an error occured during Google Authentication")
            SwiftyBeaver.error(error.localizedDescription)
            return
        }//error
        
        if user.profile.email != nil {
            social.usrEmail = user.profile.email
        } else {
            SwiftyBeaver.warning("WelcomeViewController: GIDSignInUIDelegate sign- could not get social.usrEmail")
        }//social.usrEmail
        
        SwiftyBeaver.debug("WelcomeViewController: GIDSignInUIDelegate -sign-ssocial.usrEmail = \(String(describing: social.usrEmail))")
        
        if user.profile.givenName != nil {
        
            social.usrGivenName = user.profile.givenName
            
        } else {
            SwiftyBeaver.warning("WelcomeViewController: GIDSignInUIDelegate Google sign in - could not get user given name")
        }//social.usrGivenName
        
        SwiftyBeaver.debug("WelcomeViewController: GIDSignInUIDelegate-sign-social.usrGivenName = \(String(describing: social.usrGivenName))")
        
        if user.profile.familyName != nil {
            social.usrFamilyName = user.profile.familyName
            
        } else {
            SwiftyBeaver.warning("WelcomeViewController: GIDSignInUIDelegate Google sign in - could not get user familyName")
        }//social.usrFamilyName
        
        SwiftyBeaver.debug("WelcomeViewController: GIDSignInUIDelegate-sign-ssocial.usrFamilyName = \(String(describing: social.usrGivenName))")
        
        if user.profile.hasImage {
            guard let url = (user.profile.imageURL(withDimension: 120)) else {
                SwiftyBeaver.warning("WelcomeViewController: GIDSignInUIDelegate-sign user.profile.imageURL is not found")
                return
            }//let url
        
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    SwiftyBeaver.warning("WelcomeViewController: GIDSignInUIDelegate -sign session.dataTask Failed")
                    SwiftyBeaver.warning("Error getting data from URL: \(error)")
                }//let error
        if let data = data {
            social.usrProfilePhoto  = UIImage(data: data)!
            SwiftyBeaver.debug("WelcomeViewController: GIDSignInUIDelegate-sign-social.usrProfilePhoto SUCCESS ")
        } else {
            SwiftyBeaver.warning("WelcomeViewController: GIDSignInUIDelegate-sign-social.usrProfilePhoto FAILED")
        }//let data
        
                }.resume() //session.dataTask
        }//if user.profile.hasImage
        
        guard let authentication = user.authentication else {
            SwiftyBeaver.error("WelcomeViewController: GIDSignInUIDelegate-sign")
            SwiftyBeaver.error("authentication = user.authentication")
            SwiftyBeaver.error("Firebase Authentication failed")
            return
            
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
        accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if (error) != nil {
                SwiftyBeaver.error("WelcomeViewController: GIDSignInDelegate Google Authentification Failed \(String(describing: error?.localizedDescription))")
            } else {
                SwiftyBeaver.info("WelcomeViewController: GIDSignInDelegate Google Firebase Authentification Success")
                self.goToMap()
        }//error
    }//Auth
}//sign
    
    func getImageFromUrl(sourceUrl: String) -> UIImage? {
        if let url = URL(string: sourceUrl) {
            if let imageData = try? Data(contentsOf:url) {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
}//extention


