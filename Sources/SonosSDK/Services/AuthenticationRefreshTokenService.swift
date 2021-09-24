//
//  File.swift
//  
//
//  Created by James Hickman on 2/10/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct AuthenticationRefreshTokenService {
        
    func refreshAuthenticationToken(token: AuthenticationToken, encodedKeys: String, success: @escaping (AuthenticationToken) -> (), failure: @escaping (Error?) -> ()) {
        AuthenticationRefreshTokenNetwork(refreshToken: token.refresh_token, encodedKeys: encodedKeys) { data in
            guard let data = data,
                  let token = AuthenticationToken(data) else {
                let error = NSError.errorWithMessage(message: "Could not create authentication token.")
                failure(error)
                return
            }
            success(token)
        } failure: { error in
            failure(error)
        }.performRequest()
    }
            
}
