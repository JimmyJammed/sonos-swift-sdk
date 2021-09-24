//
//  File.swift
//  
//
//  Created by James Hickman on 2/20/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct PlayerVolumeService {
    
    func getVolume(authenticationToken: AuthenticationToken, playerID: String, success: @escaping (PlayerVolume) -> (), failure: @escaping (Error?) -> ()) {
        PlayerVolumeGetNetwork(accessToken: authenticationToken.access_token, playerId: playerID) { data in
            guard let data = data,
                  let playerVolume = PlayerVolume(data) else {
                let error = NSError.errorWithMessage(message: "Could not create PlayerVolume object.")
                failure(error)
                return
            }
            success(playerVolume)
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func setVolume(authenticationToken: AuthenticationToken, playerID: String, volume: Int, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        PlayerSetVolumeNetwork(accessToken: authenticationToken.access_token, playerId: playerID, volume: volume) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }
    
    func setMuted(authenticationToken: AuthenticationToken, playerID: String, muted: Bool, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        PlayerSetMuteNetwork(accessToken: authenticationToken.access_token, playerId: playerID, muted: muted) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func setRelativeVolume(authenticationToken: AuthenticationToken, playerID: String, relativeVolume: Int, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        PlayerSetRelativeVolumeNetwork(accessToken: authenticationToken.access_token, playerId: playerID, volumeDelta: relativeVolume) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func subscribe(authenticationToken: AuthenticationToken, playerID: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        PlayerVolumeSubscribeNetwork(accessToken: authenticationToken.access_token, playerId: playerID) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func unsubscribe(authenticationToken: AuthenticationToken, playerID: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        PlayerVolumeUnsubscribeNetwork(accessToken: authenticationToken.access_token, playerId: playerID) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

}
