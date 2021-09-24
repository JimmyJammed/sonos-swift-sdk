//
//  File.swift
//  
//
//  Created by James Hickman on 2/9/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct AuthenticationTokenService {

    func getAuthenticationToken(authorization: Authorization, encodedKeys: String, redirectURI: String, success: @escaping (AuthenticationToken) -> (), failure: @escaping (Error?) -> ()) {
        AuthenticationTokenNetwork(authorizationCode: authorization.code, encodedKeys: encodedKeys, redirectURI: redirectURI) { data in
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
