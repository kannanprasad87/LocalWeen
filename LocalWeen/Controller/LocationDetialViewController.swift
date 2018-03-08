//
//  LocationDetialViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.


import UIKit
import Cosmos
import CoreLocation
import Agrume
import GoogleMaps


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
    @IBOutlet weak var existingPhotos: UIImageView!
    
    
    //My code
    var agrume: Agrume!
    // current image to track which image to view
    var currentImage = 0
    // Array of photoes
    var photos = [UIImage?]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cosmosView.rating = 0
        reverseGeocodeCoordinate(coord!)
        print("getLocationPhotos")
        getLocationPhotos(coordinate: coord!)
        
        if cosmosView.rating <= 0  {
            addButton.isEnabled = false
        }//if
        cosmosView.didFinishTouchingCosmos = didFinishTouchingCosmos
        cosmosView.didTouchCosmos = didTouchCosmos
        picker?.delegate = self
        userChosenPhotoFromGalleryOrCamera.isHidden = true
        usrGivenName.text = social.usrGivenName
        usrProfilePhoto.image = social.usrProfilePhoto
        averageRating(coordinate: coord!)
        
        // prepare UIImage view for swipe gesture recognizer
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(gestureRecognizer:)))
        leftSwipeGesture.direction = UISwipeGestureRecognizerDirection.left
        existingPhotos.isUserInteractionEnabled = true
        existingPhotos.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(gestureRecognizer:)))
        rightSwipeGesture.direction = UISwipeGestureRecognizerDirection.right
        existingPhotos.addGestureRecognizer(rightSwipeGesture)
        
    }//viewDidLoad
    
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
        }//guard
        // store location rating and possibly image path if an image was chosen
        if userChosenPhotoFromGalleryOrCamera.image != nil {
            let imageName:String = storageHandler.upLoad(imageToUpload: userChosenPhotoFromGalleryOrCamera.image!)
            dbHandler.addLocation(coordinate: coordinate, rating: cosmosView.rating, imageName: imageName)
        } else {
            //don't upload an image, just save the location rating and coord
            dbHandler.addLocation(coordinate: coordinate, rating: cosmosView.rating, imageName: "")
        }//else
    }//addButton
    
    //MARK Cosmos Ratings
    private func didTouchCosmos(_ rating: Double){
        addButton.isEnabled = true
    }//didTouchCosmos
    
    private func didFinishTouchingCosmos(_ rating: Double){
        addButton.isEnabled = true
    }//didFinishTouchingCosmos
    
    //MARK: Choose Photo
    @IBAction func addPhoto(_ sender: Any) {
        openGallary()
    }//addPhoto
    
    @IBAction func addPhotoFromCamera(_ sender: Any) {
        openCamera()
    }//addPhotoFromCamera
    
    private func openGallary()
    {
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker!, animated: true, completion: nil)
    }//openGallary
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        userChosenPhotoFromGalleryOrCamera.image = chosenImage
        
        dismiss(animated: true, completion: nil)
        userChosenPhotoFromGalleryOrCamera.isHidden = false
    }//imagePickerController
    
    private func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }//else
    }//openCamera
    
    //MARK: Get Location Photos
    func getLocationPhotos(coordinate:CLLocationCoordinate2D){
        dbHandler.getFor(coordinateIn: coordinate, what: "fileNames") { (fileNames) in
            for file in fileNames {
                //grab photo and stick it in the UI
                let image = self.storageHandler.downLoad(filename: file as! String)
                //take the downloaded photos and put them into a very nice photo gallery
                // Add photo to the array of photos
                if let photo = image.image {
                    self.photos.append(photo)
                    self.existingPhotos.image = photo
                }//if
            }//for
        }//dbHandler
    }//getLocationPhotos
    
    func averageRating(coordinate:CLLocationCoordinate2D){
        var totalRating:Double = 0
        print("averageRating(coordinate: \(String(describing: coordinate))")
        
        dbHandler.getFor(coordinateIn: coordinate, what: "ratings") { (ratings) in
            for rating in ratings {
                totalRating += rating as! Double
            }//for ratings
            
            guard totalRating >= 1.0 else { return}
            var av:Double = 0
            av = (Double(totalRating))/(Double(ratings.count))
            if av < 1 {
                self.averageRatingLabel.text = ""
            }
            let avRatingStr = String(format: "%.2f", ceil(av * 100)/100)
            self.averageRatingLabel.text = "Average: " + avRatingStr
        
            
        }//dbHandler
    }//averageRating
    
    @IBAction func Back(_ sender: UIButton) {
        performSegue(withIdentifier: "toMap", sender: self)
    }//Back
    
    
    // gesture recognizer code
    @objc func imageSwiped(gestureRecognizer: UIGestureRecognizer) {
        var currentImage = 0
        var photos = [UIImage?]()
        
        if let swipeGesture = gestureRecognizer as? UISwipeGestureRecognizer{
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left :
                print("left Swipe")
                if currentImage == photos.count - 1 {
                    currentImage = 0
                    
                }else{
                    currentImage += 1
                    
                }
                // show photo on the imageView
                
                //INDEX OUT OF RANGE ON FIRST RUN ONLY
                if let image = photos[currentImage]{
                    self.existingPhotos.image = image
                }
            case UISwipeGestureRecognizerDirection.right:
                print("Right Swipe")
                if currentImage == 0 {
                    print("photos.count = \(photos.count)")
                    print("photos.count = \(photos.count - 1)")
                    
                    //HERE PHOTOS.COUNT CAN BE - 1 IF SWIPE LEFT
                    currentImage = photos.count - 1
                }else{
                    currentImage -= 1
                    
                }
                // show photo on the imageView
                //ON LEFT SWIPE THIS IS INDEX OUT OF RANGE
                print("currentImage \(String(describing: currentImage ))")
                if let image = photos[currentImage]{
                    self.existingPhotos.image = image
                }
            default:
                break
            }
        }
        
    }
    
}//LocationDetailViewController
