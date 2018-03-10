//
//  OpenInGoogleMaps.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/8/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import GoogleMaps
import CoreLocation
import OpenInGoogleMaps

class Directions {
    
    func googleMaps(fromCoord: CLLocationCoordinate2D, toCoord:CLLocationCoordinate2D){
        let mycallbackURL = URL(string: "localweenapp://")
        OpenInGoogleMapsController.sharedInstance().callbackURL = mycallbackURL
        
        let definition = GoogleDirectionsDefinition()
        definition.destinationPoint = GoogleDirectionsWaypoint(location: toCoord)
        definition.startingPoint = GoogleDirectionsWaypoint(location: fromCoord)
        definition.travelMode = GoogleMapsTravelMode.driving
        OpenInGoogleMapsController.sharedInstance().openDirections(definition)
        OpenInGoogleMapsController.sharedInstance().callbackURL = mycallbackURL
    }
    
}//Directions
