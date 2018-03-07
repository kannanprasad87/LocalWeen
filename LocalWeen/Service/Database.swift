//
//  Database.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/3/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import FirebaseDatabase
import CoreLocation

class DBHandler{
    var ref:DatabaseReference! = Database.database().reference().child("locations")
    
    
    func getFor(coordinateIn:CLLocationCoordinate2D?, what: String, completion: @escaping ([Any]) -> ())  {
        
        var ratings = [Double]()
        var fileNames = [String]()
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot =  snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot {
                    if let data = snap.value as? [String:Any]{
                        //Get the lattitude and longitude for matching
                        guard let lattitude = data["lattitude"] else {
                            return
                        }
                        guard let longitude = data["longitude"] else {
                            return
                            
                        }
                        let coordFromDB = CLLocationCoordinate2DMake(lattitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
                        
                        let isMatch = self.matchCoords(coordinateIn: coordinateIn!, coordFromDB: coordFromDB)
                        
                        switch what {
                            
                            case "fileNames":
                                guard let filename = data["image_name"] else {
                                    return
                                }
                                if isMatch {
                                        fileNames.append(filename as! String)
                                }//if isMatch
                            
                            case "ratings":
                            
                                guard let ratingData = data["rating"] else {
                                    return
                                }
                                
                                if isMatch {
                                    
                                    let rating = ratingData as! Double
                                    if rating >= 1.0 {
                                        ratings.append(rating)
                                    } else {
                                        print("Rating was less than 1")
                                    }
                                    ratings.append(rating)
                                }//isMatch
                            
                            case "coordinate":
                                var coordinates = [CLLocationCoordinate2D]()
                                coordinates.append(coordFromDB)

                        default:
                            return
                        }//switch
                    }//data
                }//for
            }//snapshot
        }//ref
    }//get
    
    private func matchCoords(coordinateIn:CLLocationCoordinate2D, coordFromDB:CLLocationCoordinate2D) -> Bool {
        
        if coordinateIn.latitude == coordFromDB.latitude && coordinateIn.longitude == coordFromDB.longitude {
            return true
        } else {
            return false
        }
    }//matchCoords

    
    func addLocation(coordinate:CLLocationCoordinate2D, rating: Double, imageName: String?){
        let location = ["latitude": coordinate.latitude,
                        "longitude": coordinate.longitude,
                        "rating": rating,
                        "image_name": imageName!,
                        "postDate": ServerValue.timestamp()
            ] as [String : Any]
        self.ref.childByAutoId().setValue(location)
    }//end setLocation
    
    
}//DBHandler
    

    