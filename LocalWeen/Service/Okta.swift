//
//  Okta.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/18/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import Foundation
import Okta

OktaAuth
    .login()
    .start(self) { response, error in
        if error != nil { print(error!) }
        
        // Success
        if let tokenResponse = response {
            OktaAuth.tokens.set(
                value: tokenResponse.accessToken!,
                forKey: "accessToken"
            )
            OktaAuth.tokens.set(
                value: tokenResponse.idToken!,
                forKey: "idToken"
            )
            OktaAuth.tokens.set(
                value: tokenResponse.refreshToken!,
                forKey: "refreshToken"
            )
        }
}
