//
//  File.swift
//  
//
//  Created by James Hickman on 3/21/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct GroupVolumeService {

    func getVolume(authenticationToken: AuthenticationToken, groupId: String, success: @escaping (GroupVolume) -> (), failure: @escaping (Error?) -> ()) {
        GroupVolumeGetNetwork(accessToken: authenticationToken.access_token, groupId: groupId) { data in
            guard let data = data,
                  let groupVolume = GroupVolume(data) else {
                let error = NSError.errorWithMessage(message: "Could not create GroupVolume object.")
                failure(error)
                return
            }
            success(groupVolume)
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func setVolume(authenticationToken: AuthenticationToken, groupId: String, volume: Int, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        GroupVolumeSetNetwork(accessToken: authenticationToken.access_token, groupId: groupId, volume: volume) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func setMuted(authenticationToken: AuthenticationToken, groupId: String, muted: Bool, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        GroupVolumeSetMuteNetwork(accessToken: authenticationToken.access_token, groupId: groupId, muted: muted) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func setRelativeVolume(authenticationToken: AuthenticationToken, groupId: String, relativeVolume: Int, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        GroupVolumeSetRelativeVolumeNetwork(accessToken: authenticationToken.access_token, groupId: groupId, volumeDelta: relativeVolume) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func subscribe(authenticationToken: AuthenticationToken, groupId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        GroupVolumeSubscribeNetwork(accessToken: authenticationToken.access_token, groupId: groupId) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func unsubscribe(authenticationToken: AuthenticationToken, groupId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        GroupVolumeUnsubscribeNetwork(accessToken: authenticationToken.access_token, groupId: groupId) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

}
