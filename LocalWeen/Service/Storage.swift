//
//  Storage.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/3/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import Foundation

import UIKit
import FirebaseStorage
import FirebaseStorageUI

struct StorageHandler {
    
    private var imageData = Data()
    private let childName:String = "images"
    
    private var imageReference: StorageReference {
        return Storage.storage().reference().child(childName)
    }
    
    func upLoad(imageToUpload: UIImage) -> String {
        
        let image = imageToUpload
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return "" }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let formatter = DateFormatter()
        formatter.dateFormat = "MM_DD_yyyy_hh_mm_ss"
        let filename = "\(formatter.string(from: NSDate() as Date)).jpg"
        let uploadImageRef = imageReference.child(filename)
        
        
        let uploadTask = uploadImageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if metadata == nil{
                fatalError("Missing image metadata")
            }
            if error != nil {
                fatalError("uploadTask had an error \(String(describing: error))")
            }
            
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress ?? "NO MORE PROGRESS")
        }
        
        uploadTask.resume()
        return filename
    }//upload
    
    func downLoad(filename: String) -> UIImageView{
        let reference = imageReference.child(filename)
        let imageView: UIImageView = UIImageView()
        imageView.sd_setImage(with: reference)
        return imageView
    }
}
