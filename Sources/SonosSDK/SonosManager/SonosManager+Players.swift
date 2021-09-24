//
//  File.swift
//  
//
//  Created by James Hickman on 2/19/21.
//

import Foundation

extension SonosManager {

    public func getPlayers(householdId: String, group: Group, success: @escaping ([Player]) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        playerService.getPlayers(authenticationToken: authenticationToken, householdId: householdId, success: { players in
            let groupPlayers = players.filter { return group.playerIDs.contains($0.id) }
            self.container.register([Player].self) { _ in players }
            success(groupPlayers)
        }, failure: failure)
    }

}
