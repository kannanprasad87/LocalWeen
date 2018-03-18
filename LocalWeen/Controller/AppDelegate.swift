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
import SwiftyBeaver

class socialProfile{
    var usrGivenName = ""
    var usrFamilyName = ""
    var usrEmail = ""
    var usrProfilePhoto = UIImage()
}

let social = socialProfile()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupSwiftyBeaverLogging()
        
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
    
    func setupSwiftyBeaverLogging(){
    
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss$d $C$L$c: $M"
        SwiftyBeaver.addDestination(console)
        let platform = SBPlatformDestination(appID: "pgxG5z",
                                             appSecret: "rYlivwwdlfaKyfBSbhgU8yNmt5bcNNdn",
                                             encryptionKey: "RlrWwk0ciktIadaslZ17oenoabydnzyy")
        
        SwiftyBeaver.addDestination(platform)
        let file = FileDestination()
        SwiftyBeaver.addDestination(file)

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
        guard case social.usrEmail? = user.profile.email else {
            SwiftyBeaver.warning("AppDelegate-sign- could not get social.usrEmail")
            return
        }
        
        SwiftyBeaver.debug("AppDelegate-sign-ssocial.usrEmail = \(String(describing: social.usrEmail))")
        
        guard case social.usrGivenName? = user.profile.givenName else {
            SwiftyBeaver.warning("Google sign in - could not get user given name")
            return
        }
        
        SwiftyBeaver.debug("AppDelegate-sign-social.usrGivenName = \(String(describing: social.usrGivenName))")
        
        guard case social.usrFamilyName? = user.profile.familyName else {
            SwiftyBeaver.warning("Google sign in - could not get user familyName")
            return
        }
        
         SwiftyBeaver.debug("AppDelegate-sign-ssocial.usrFamilyName = \(String(describing: social.usrGivenName))")
        
        if user.profile.hasImage {
            guard let url = (user.profile.imageURL(withDimension: 120)) else {
                SwiftyBeaver.warning("AppDelegate-sign user.profile.imageURL is not found")
                return
            }
           
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    SwiftyBeaver.warning("AppDelegate-sign-session.dataTask Failed")
                    SwiftyBeaver.warning("Error getting data from URL: \(error)")
                }
                if let data = data {
                    social.usrProfilePhoto  = UIImage(data: data)!
                    SwiftyBeaver.debug("AppDelegate-sign-social.usrProfilePhoto SUCCESS ")
                } else {
                    SwiftyBeaver.warning("AppDelegate-sign-social.usrProfilePhoto FAILED")
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
