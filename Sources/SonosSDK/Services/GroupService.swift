//
//  File.swift
//  
//
//  Created by James Hickman on 2/17/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct GroupService {
            
    func getGroups(authenticationToken: AuthenticationToken, householdId: String, success: @escaping ([Group], [Player]) -> (), failure: @escaping (Error?) -> ()) {
        GroupGetNetwork(accessToken: authenticationToken.access_token, householdId: householdId) { data in
            let results = data.map({ self.decode($0) })
            guard let groups = results?.0,
                  let players = results?.1 else {
                let error = NSError.errorWithMessage(message: "Could not create a GroupNetwork object from response data.")
                failure(error)
                return
            }
            success(groups, players)
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func modifyGroupMembers(authenticationToken: AuthenticationToken, groupId: String, playerIdsToAdd: [String], playerIdsToRemove: [String], success: @escaping (Group?, Error?) -> (), failure: @escaping (Error?) -> ()) {
        GroupModifyMembersNetwork(accessToken: authenticationToken.access_token, groupId: groupId, playerIdsToAdd: playerIdsToAdd, playerIdsToRemove: playerIdsToRemove) { data in
            guard let data = data else {
                success(nil, nil)
                return
            }
            success(self.decodeGroups(data), NSError.errorWithData(data: data))
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func subscribe(authenticationToken: AuthenticationToken, householdId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        GroupSubscribeNetwork(accessToken: authenticationToken.access_token, householdId: householdId) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func unsubscribe(authenticationToken: AuthenticationToken, householdId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        GroupUnsubscribeNetwork(accessToken: authenticationToken.access_token, householdId: householdId) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    fileprivate func decode(_ data: Any) -> ([Group], [Player]) {
        let json = JSON(data)
        var groups = [Group]()
        for group in json["groups"].arrayValue {
            if let group = Group(group) {
                groups.append(group)
            }
        }
    
        var players = [Player]()
        for player in json["players"].arrayValue {
            if let player = Player(player) {
                players.append(player)
            }
        }

        return (groups, players)
    }

    fileprivate func decodeGroupMembers(_ data: Any) -> [Player] {
        let json = JSON(data)
        var players = [Player]()
        for player in json["players"].arrayValue {
            if let player = Player(player) {
                players.append(player)
            }
        }
        return players
    }

    fileprivate func decodeGroups(_ data: Any) -> Group? {
        let json = JSON(data)
        return Group(json["group"].dictionaryValue)
    }

}
