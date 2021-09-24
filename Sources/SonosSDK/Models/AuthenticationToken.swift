//
//  File.swift
//  
//
//  Created by James Hickman on 2/7/21.
//

import Foundation
import SwiftyJSON

public struct AuthenticationToken: Codable {

    var access_token: String
    var token_type: String
    var refresh_token: String
    var expires_in: Int
    var scope: String
    var expireDate: Date

    var isExpired: Bool {
        return expireDate < Date()
    }
    
    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let access_token = json["access_token"].string,
              let expires_in = json["expires_in"].int,
              let refresh_token = json["refresh_token"].string,
              let scope = json["scope"].string,
              let token_type = json["token_type"].string else {
            return nil
        }
        self.access_token = access_token
        self.expires_in = expires_in
        self.expireDate = Date(timeIntervalSinceNow: TimeInterval(expires_in))
        self.refresh_token = refresh_token
        self.scope = scope
        self.token_type = token_type
    }
}
