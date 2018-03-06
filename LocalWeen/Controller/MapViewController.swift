//
//  MapViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
import GoogleSignIn

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    private var locationOfInterestMarker = GMSMarker()
    private var userMarker = GMSMarker()
    var locationManager = CLLocationManager()
    private let zoom:Float = 15
    let locationOfInterestImage:String = "hhouseicon"
    let userMarkerImage:String = "witchicon"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.getLocations()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        self.locationManager.startUpdatingLocation()
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        self.locationManager.stopUpdatingLocation()
        self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        self.placeMarker(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, marker: self.userMarker, imageName: userMarkerImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destination = segue.destination as? LocationDetialViewController {
            
            destination.coordinate = locationManager.location?.coordinate
        } else {
            return
        }
    }
    
    func getLocations(){
        let ref:DatabaseReference = Database.database().reference().child("locations")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot =  snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot {
                    if let data = snap.value as? [String:Any]{
                        let lattitude = data["latitude"]
                        let longitude = data["longitude"]
                        self.placeMarker(latitude: lattitude as! Double, longitude: longitude as! Double, marker: self.locationOfInterestMarker, imageName: self.locationOfInterestImage)
                    }//end if
                    else{
                        fatalError("Can't get a Firebase snapshot")
                    }
                }//end for
            }//end if
        }//end ref
    }//end getData
    
    func placeMarker(latitude: Double, longitude:Double, marker: GMSMarker, imageName: String){
        
        let myMarker = marker
        myMarker.map = nil
        myMarker.map = self.mapView
        myMarker.icon = UIImage(named: imageName)
        myMarker.position = CLLocationCoordinate2DMake(latitude, longitude)
        
    }

    
    @IBAction func didTapSignOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        performSegue(withIdentifier: "toDetail", sender: self)
        return false
    }
    
}//MapViewController


