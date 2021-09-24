//
//  File.swift
//  
//
//  Created by James Hickman on 2/17/21.
//

import Foundation

extension SonosManager {

    public func getHouseholds(success: @escaping ([Household]) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        householdService.getHouseholds(authenticationToken: authenticationToken, success: { households in
            self.container.register([Household].self) { _ in households }
            success(households)
        }, failure: failure)
    }

}
