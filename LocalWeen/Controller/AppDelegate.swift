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

//MARK: Social Profile

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
}
