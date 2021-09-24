//
//  File.swift
//  
//
//  Created by James Hickman on 2/10/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct HouseholdService {
            
    func getHouseholds(authenticationToken: AuthenticationToken, success: @escaping ([Household]) -> (), failure: @escaping (Error?) -> ()) {
        HouseholdNetwork(accessToken: authenticationToken.access_token) { data in
            guard let households = data.map({ self.decode($0) }) else {
                let error = NSError.errorWithMessage(message: "Could not create Household objects.")
                failure(error)
                return
            }
            success(households)
        } failure: { error in
            failure(error)
        }.performRequest()
    }
    
    fileprivate func decode(_ data: Any) -> [Household] {
        
        let json = JSON(data)
        var households = [Household]()
        for household in json["households"].arrayValue {
            if let household = Household(household) {
                households.append(household)
            }
        }
        return households
        
    }
    
}
