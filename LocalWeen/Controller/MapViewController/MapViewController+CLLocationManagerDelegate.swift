//
//  MapViewController+CLLocationManagerDelegate.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/15/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//


import GoogleMaps
import SwiftyBeaver

extension MapViewController {
    func startUpLocationManager(){
        //Location Manager and Map View Delegate
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
        self.mapView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            SwiftyBeaver.info("authorizedWhenInUse = \(String(describing: status ))")
            self.mapView.settings.myLocationButton = true
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        self.placeMarker(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, imageName: userMarkerImage)
        segueWhat = dataToSegue.userLocation
    }
}
