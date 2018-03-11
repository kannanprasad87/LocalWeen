//
//  AppDelegate.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import GoogleSignIn
import GooglePlaces


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyCAL3awSh-YPf9HwawGLjBjukc6Kz9478k")
        GMSPlacesClient.provideAPIKey("AIzaSyD2RJCP9eoFaL3HPPfbYaetg_8BWhXCa24")
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let googleAuthentication = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        
        
        return googleAuthentication
    }
    
    
    // Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            print("Either the user already signed out or an error occured during Google Authentication")
            return
        }
        //MARK: HERE WE CAN GRAB USER'S SOCIAL INFO
        
        social.usrEmail = user.profile.email
        social.usrGivenName = user.profile.givenName
        if user.profile.hasImage {
            //MARK: FIGURE OUT HOW TO GET URL TO IMAGE, can't find the code that works
            guard let url = (user.profile.imageURL(withDimension: 120)) else {
                print("No url found for user social profile.  user.profile.imageURL is not found")
                return
            }
           
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error getting data from URL: \(error)")
                }
                if let data = data {
                    social.usrProfilePhoto  = UIImage(data: data)!
                 }
            }.resume() //session.dataTask
        }//if user.profile.hasImage
        
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if (error) != nil {
                print("Google Authentification Fail")
            } else {
                print("Google Authentification Success")
                
                let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = protectedPage
                
            }
        }
    }
    
}
