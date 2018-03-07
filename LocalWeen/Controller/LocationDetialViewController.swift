//
//  LocationDetialViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.


import UIKit
import GoogleMaps
import Cosmos
import CoreLocation


class LocationDetialViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public var coord:CLLocationCoordinate2D? = CLLocationCoordinate2D()
    private let dbHandler = DBHandler()
    private let storageHandler = StorageHandler()
    private let locationManager = CLLocationManager()
    private var picker:UIImagePickerController?=UIImagePickerController()
    
    //Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var userChosenPhotoFromGalleryOrCamera: UIImageView!
    @IBOutlet weak var usrProfilePhoto: UIImageView!
    @IBOutlet weak var usrGivenName: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cosmosView.rating = 0
        reverseGeocodeCoordinate(coord!)
        getLocationPhotos(coordinate: coord!)
        if cosmosView.rating <= 0  {
            addButton.isEnabled = false
        }
        cosmosView.didFinishTouchingCosmos = didFinishTouchingCosmos
        cosmosView.didTouchCosmos = didTouchCosmos
        picker?.delegate = self
        userChosenPhotoFromGalleryOrCamera.isHidden = true
        usrGivenName.text = social.usrGivenName
        usrProfilePhoto.image = social.usrProfilePhoto
        averageRating(coordinate: coord!)
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
        guard let coordinate = self.coord else {
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
    
    //MARK Cosmos Ratings
    private func didTouchCosmos(_ rating: Double){
        addButton.isEnabled = true
    }
    
    private func didFinishTouchingCosmos(_ rating: Double){
        addButton.isEnabled = true
    }
    
    //MARK: Choose Photo
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
    
    //MARK: Get Location Photos
    func getLocationPhotos(coordinate:CLLocationCoordinate2D){
        dbHandler.getMatching(coordinate: coordinate) { (photoNames) in
            for photo in photoNames {
                //grab photo and stick it in the UI
                
            }//for
        }//getMatching
    }//getLocationPhotos
    
    func averageRating(coordinate:CLLocationCoordinate2D){
        var totalRating:Double = 0
        dbHandler.getRatings(coordinate: coordinate) { (ratings) in
            for rating in ratings {
                
                totalRating += rating as Double
                
            }
            var av:Double = 0
            av = (Double(totalRating))/(Double(ratings.count))
            let avRatingStr = String(format: "%.2f", ceil(av * 100)/100)
            self.averageRatingLabel.text = "Average: " + avRatingStr

        }
    }
    
    @IBAction func Back(_ sender: UIButton) {
        performSegue(withIdentifier: "toMap", sender: self)
        
    }
    
    
}//LocationDetailViewController
