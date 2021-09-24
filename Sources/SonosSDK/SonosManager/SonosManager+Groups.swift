//
//  File.swift
//  
//
//  Created by James Hickman on 2/17/21.
//

import Foundation

extension SonosManager {

    public func getGroups(householdId: String, success: @escaping ([Group], [Player]) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupService.getGroups(authenticationToken: authenticationToken, householdId: householdId, success: { groups, players in
            success(groups, players)
        }, failure: failure)
    }

    public func getGroupMembers(group: Group, players: [Player]) -> [Player] {
        let groupPlayers = players.filter { return group.playerIDs.contains($0.id) }
        return groupPlayers
    }

    public func modifyGroupMembers(groupId: String, playerIdsToAdd: [String], playerIdsToRemove: [String], success: @escaping (Group?, Error?) -> Void, failure: @escaping (Error?) -> Void) {

        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupService.modifyGroupMembers(authenticationToken: authenticationToken, groupId: groupId, playerIdsToAdd: playerIdsToAdd, playerIdsToRemove: playerIdsToRemove, success: { group, error in
            success(group, error)
        }, failure: failure)
    }

    public func subscribeToGroups(forHouseholdId householdId: String, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupService.subscribe(authenticationToken: authenticationToken, householdId: householdId, success: success, failure: failure)
    }

    public func unsubscribeToGroups(forHouseholdId householdId: String, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupService.unsubscribe(authenticationToken: authenticationToken, householdId: householdId, success: success, failure: failure)
    }

}
