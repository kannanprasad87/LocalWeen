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
import GooglePlaces

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    //Map Support
    @IBOutlet weak var mapView: GMSMapView!
    private var locationOfInterestMarker = GMSMarker()
    private var userMarker = GMSMarker()
    var locationManager = CLLocationManager()
    
    //Constants
    private let zoom:Float = 15
    let locationOfInterestImage = "hhouseicon"
    let userMarkerImage = "witchicon"
    let questionMarker = "questionMapMaker"
    
    //Search Bar Support
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var isSearchResult:Bool = Bool()
    var searchCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Search Bar
        isSearchResult = false
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        //Location Manager and Map View Delegate
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        
        //Get all stored locations and place marker
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
        
        if isSearchResult {
            //User searched for a location so maybe they want to add it
            //and maybe they want to drive there
            
            directions.toCoordinate = searchCoordinates
            
                if let destination = segue.destination as? LocationDetialViewController {
                    
                    
                    destination.coord = searchCoordinates
                } else {
                    return
                }
            
        } else {
                //User's current location
                if let destination = segue.destination as? LocationDetialViewController {
              
                    destination.coord = locationManager.location?.coordinate
                } else {
                    return
                }
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

extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        placeMarker(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, marker: locationOfInterestMarker, imageName: questionMarker)
        self.mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
        isSearchResult = true
        searchCoordinates = place.coordinate
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

