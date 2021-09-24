//
//  File.swift
//  
//
//  Created by James Hickman on 3/21/21.
//

import Foundation

extension SonosManager {

    public func getGroupVolume(forGroup group: Group, success: @escaping (GroupVolume) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupVolumeService.getVolume(authenticationToken: authenticationToken, groupId: group.id, success: { groupVolume in
            success(groupVolume)
        }, failure: failure)
    }

    public func setGroupVolume(forGroup group: Group, volume: Int, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupVolumeService.setVolume(authenticationToken: authenticationToken, groupId: group.id, volume: volume, success: {
            success()
        }, failure: failure)
    }

    public func setGroupMuted(forGroup group: Group, muted: Bool, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupVolumeService.setMuted(authenticationToken: authenticationToken, groupId: group.id, muted: muted, success: success, failure: failure)
    }

    public func setGroupRelativeVolume(forGroup group: Group, relativeVolume: Int, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupVolumeService.setRelativeVolume(authenticationToken: authenticationToken, groupId: group.id, relativeVolume: relativeVolume, success: success, failure: failure)
    }

    public func subscribeToGroupVolume(forGroup group: Group, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupVolumeService.subscribe(authenticationToken: authenticationToken, groupId: group.id, success: success, failure: failure)
    }

    public func unsubscribeToGroupVolume(forGroup group: Group, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        groupVolumeService.unsubscribe(authenticationToken: authenticationToken, groupId: group.id, success: success, failure: failure)
    }

}
