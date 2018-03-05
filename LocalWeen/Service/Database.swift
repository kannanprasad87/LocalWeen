//
//  Database.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/3/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import FirebaseDatabase
import GoogleMaps

class DBHandler{
    var ref:DatabaseReference! = Database.database().reference().child("locations")
    
    func addLocation(coordinate:CLLocationCoordinate2D, rating: Double, imageName: String?){
        let location = ["latitude": coordinate.latitude,
                        "longitude": coordinate.longitude,
                        "rating": rating,
                        "image_name": imageName!,
                        "postDate": ServerValue.timestamp()
            ] as [String : Any]
        self.ref.childByAutoId().setValue(location)
    }//end setLocation
    
    
    //open func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
    
    func getMatching(coordinate:CLLocationCoordinate2D, completion: @escaping ([String?]) -> ())  {
        var images = [String]()
        
        let ref:DatabaseReference = Database.database().reference().child("locations")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot =  snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot {
                    if let data = snap.value as? [String:Any]{
                        let imageName = data["image_name"]

                        images.append(imageName as! String)
                    }//if
                    else{
                        fatalError("Can't get a Firebase snapshot")
                    }
                }//for
            }//if let
            completion(images)
        }//ref
    }//getMatching
    
}

