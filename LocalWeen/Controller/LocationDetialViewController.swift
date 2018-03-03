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
    private let storageHandler = StorageHandler()
    private let locationManager = CLLocationManager()
    private var picker:UIImagePickerController?=UIImagePickerController()
    
    //Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var userChosenPhotoFromGalleryOrCamera: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cosmosView.rating = 0
        guard let coordinate = locationManager.location?.coordinate else {
            print("Can't get user location")
            return
        }
        reverseGeocodeCoordinate(coordinate)
        if cosmosView.rating <= 0  {
            addButton.isEnabled = false
        }
        cosmosView.didFinishTouchingCosmos = didFinishTouchingCosmos
        cosmosView.didTouchCosmos = didTouchCosmos
        picker?.delegate = self
        userChosenPhotoFromGalleryOrCamera.isHidden = true
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }//let address
            self.addressLabel.text = lines.joined(separator: " , ")
        }//geocoder.reverseGeocodeCoordinate
    }//reverseGeocodeCoordinate
    
    
    @IBAction func addButton(_ sender: UIButton) {
        guard let coordinate = self.coordinate else {
            fatalError("Can't get coordinate")
        }
        // store location rating and possibly image path if an image was chosen
        if userChosenPhotoFromGalleryOrCamera.image != nil {
            let imageName:String = storageHandler.upLoad(imageToUpload: userChosenPhotoFromGalleryOrCamera.image!)
            dbHandler.addLocation(coordinate: coordinate, rating: cosmosView.rating, imageName: imageName)
        } else {
            //don't upload an image, just save the location rating and coord
            dbHandler.addLocation(coordinate: coordinate, rating: cosmosView.rating, imageName: "")
        }
        
    }
    
    private func didTouchCosmos(_ rating: Double){
        addButton.isEnabled = true
    }
    
    private func didFinishTouchingCosmos(_ rating: Double){
        addButton.isEnabled = true
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        openGallary()
    }
    
    @IBAction func addPhotoFromCamera(_ sender: Any) {
        openCamera()
    }
    
    
    private func openGallary()
    {
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker!, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        userChosenPhotoFromGalleryOrCamera.image = chosenImage
        
        dismiss(animated: true, completion: nil)
        userChosenPhotoFromGalleryOrCamera.isHidden = false
    }
    
    private func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }//openCamera
    
}//LocationDetailViewController