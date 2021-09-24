//
//  File.swift
//  
//
//  Created by James Hickman on 2/19/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct PlayerService {

    func getPlayers(authenticationToken: AuthenticationToken, householdId: String, success: @escaping ([Player]) -> (), failure: @escaping (Error?) -> ()) {
        GroupGetNetwork(accessToken: authenticationToken.access_token, householdId: householdId) { data in
            guard let players = data.map({ self.decode($0) }) else {
                let error = NSError.errorWithMessage(message: "Could not create Player objects.")
                failure(error)
                return
            }
            success(players)
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    fileprivate func decode(_ data: Any) -> [Player] {

        let json = JSON(data)
        var players = [Player]()
        for player in json["players"].arrayValue {
            if let player = Player(player) {
                players.append(player)
            }
        }
        return players

    }
}
