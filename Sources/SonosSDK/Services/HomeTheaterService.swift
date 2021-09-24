//
//  File.swift
//  
//
//  Created by James Hickman on 2/22/21.
//

import Foundation
import SonosNetworking

struct HomeTheaterService {
            
    func getOptions(authenticationToken: AuthenticationToken, playerId: String, success: @escaping (HomeTheaterOptions) -> (), failure: @escaping (Error?) -> ()) {
        HomeTheaterGetOptionsNetwork(accessToken: authenticationToken.access_token, playerId: playerId) { data in
            guard let data = data,
                  let homeTheaterOptions = HomeTheaterOptions(data) else {
                let error = NSError.errorWithMessage(message: "Could not create HomeTheaterOptions object.")
                failure(error)
                return
            }
            success(homeTheaterOptions)
        } failure: { error in
            failure(error)
        }.performRequest()
    }
    
    func setNightMode(authenticationToken: AuthenticationToken, playerId: String, enabled: Bool, success: @escaping (Error?) -> (), failure: @escaping (Error?) -> ()) {
        HomeTheaterSetOptionsNetwork(accessToken: authenticationToken.access_token, playerId: playerId, nightMode: enabled) { data in
            if let data = data, let responseError = NSError.errorWithData(data: data) {
                success(responseError)
            } else {
                success(nil)
            }
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func setEnhanceDialog(authenticationToken: AuthenticationToken, playerId: String, enabled: Bool, success: @escaping (Error?) -> (), failure: @escaping (Error?) -> ()) {
        HomeTheaterSetOptionsNetwork(accessToken: authenticationToken.access_token, playerId: playerId, enhanceDialog: enabled) { data in
            if let data = data, let responseError = NSError.errorWithData(data: data) {
                success(responseError)
            } else {
                success(nil)
            }
        } failure: { error in
            failure(error)
        }.performRequest()
    }

}
