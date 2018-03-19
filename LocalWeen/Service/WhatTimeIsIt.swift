//
//  WhatTimeIsIt.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/19/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//
import SwiftyBeaver
import Foundation
import TrueTime

class WhatTimeIsIt {
    
    func theTimeIs() -> Date {
        let trueTimeClient = TrueTimeClient.sharedInstance
        trueTimeClient.start()
        
        let now = trueTimeClient.referenceTime?.now()
        
        // To block waiting for fetch, use the following:
        trueTimeClient.fetchIfNeeded { result in
        switch result {
            case let .success(referenceTime):
                let now = referenceTime.now()
                SwiftyBeaver.verbose("WhatTimeIsIt.theTimeIs.client.fetchIfNeeded got the time \(String(describing: now))")
                return
            case let .failure(error):
                SwiftyBeaver.error("WhatTimeIsIt.theTimeIs ERROR: \(error)")
                return
            }//switch
        }//client
        SwiftyBeaver.verbose("WhatTimeIsIt.theTimeIs Returning \(String(describing: now))")
        return now!
    }//theTimeIs
}//WhatTimeIsIt
