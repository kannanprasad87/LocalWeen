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
}

