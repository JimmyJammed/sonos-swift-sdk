//
//  File.swift
//  
//
//  Created by James Hickman on 2/22/21.
//

import Foundation

extension SonosManager {

    public func getHomeTheaterOptions(playerId: String, success: @escaping (HomeTheaterOptions) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        homeTheaterService.getOptions(authenticationToken: authenticationToken, playerId: playerId, success: { homeTheaterOptions in
            success(homeTheaterOptions)
        }, failure: failure)
    }
    
    public func setNightMode(playerId: String, enabled: Bool, success: @escaping (Error?) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        homeTheaterService.setNightMode(authenticationToken: authenticationToken, playerId: playerId, enabled: enabled, success: success, failure: failure)
    }

    public func setEnhanceDialog(playerId: String, enabled: Bool, success: @escaping (Error?) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        homeTheaterService.setEnhanceDialog(authenticationToken: authenticationToken, playerId: playerId, enabled: enabled, success: success, failure: failure)
    }

}
