//
//  LocationDetialViewController+Agrume.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/9/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//
import Agrume
import UIKit
import CoreLocation

extension LocationDetialViewController {
  
    
    @objc func imageSwiped(gestureRecognizer: UIGestureRecognizer) {
        if let swipeGesture = gestureRecognizer as? UISwipeGestureRecognizer, photos.count > 0{
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left :
                print("left Swipe")
                if currentImage == photos.count - 1 {
                    currentImage = 0
                    
                } else {
                    currentImage += 1
                    
                }//else
                // show photo on the imageView
                if let image = photos[currentImage]{
                    self.locationPhotos.image = image
                }//if
            case UISwipeGestureRecognizerDirection.right:
                print("Right Swipe")
                if currentImage == 0 {
                    currentImage = photos.count - 1
                }else{
                    currentImage -= 1
                }
                // show photo on the imageView
                if let image = photos[currentImage]{
                    self.locationPhotos.image = image
                }
            default:
                break
            }//switch
        }//swipeGesture
    }//imageSwiped
    
    //MARK: Get Location Photos
    func getLocationPhotos(coordinate:CLLocationCoordinate2D){
        let dbHandler = DBHandler()
        let storageHandler = StorageHandler()
        dbHandler.getFor(coordinateIn: coordinate, what: "fileNames") { (fileNames) in
            for file in fileNames {
                //grab photo and stick it in the UI
                if file as! String != "" {
                    storageHandler.downLoad(filename: file as! String, completion: { (photoView) in
                        if let image = photoView.image {
                            self.photos.append(image)
                            self.locationPhotos.image = image
                        }//image
                    })//storageHandler
                }//file
            }//for file
        }//dbHandler
    }//getLocationPhotos
    
}//extension LocationDetialViewController

