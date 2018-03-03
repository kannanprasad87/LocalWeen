//
//  LocationDetialViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.


import UIKit
import GoogleMaps
import Cosmos
import GoogleSignIn


class LocationDetialViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    public var coordinate:CLLocationCoordinate2D? = CLLocationCoordinate2D()
    private let dbHandler = DBHandler()
    private let locationManager = CLLocationManager()
    private var picker:UIImagePickerController?=UIImagePickerController()
    
    //Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var userChosenPhotoFromGalleryOrCamera: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let coordinate = locationManager.location?.coordinate else {
            print("Can't get user location")
            return
        }
    }
    
    

}
