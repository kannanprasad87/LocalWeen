//
//  AppDelegate.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMaps
import GooglePlaces
import FBSDKCoreKit

class socialProfile{
    var usrGivenName = ""
    var usrEmail = ""
    var usrProfilePhoto = UIImage()
}

class FromTo{
    var fromAddress = CLLocationCoordinate2D()
    var toAddress = CLLocationCoordinate2D()
    
}

let social = socialProfile()
let fromTo = FromTo()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Google Firebase
        FirebaseApp.configure()
        
        //Google Maps
        GMSServices.provideAPIKey("AIzaSyCAL3awSh-YPf9HwawGLjBjukc6Kz9478k")
        //Google Places
        GMSPlacesClient.provideAPIKey("AIzaSyD2RJCP9eoFaL3HPPfbYaetg_8BWhXCa24")
        
        //Google sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        //Facebook sign in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
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
        social.usrEmail = user.profile.email
        social.usrGivenName = user.profile.givenName
        if user.profile.hasImage {
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
