//
//  File.swift
//  
//
//  Created by James Hickman on 2/22/21.
//

import Foundation
import SonosNetworking

struct PlayerSettingsService {
            
    func getSettings(authenticationToken: AuthenticationToken, playerID: String, success: @escaping (PlayerSettings) -> (), failure: @escaping (Error?) -> ()) {
        PlayerGetSettingsNetwork(accessToken: authenticationToken.access_token, playerId: playerID) { data in
            guard let data = data,
                  let playerSettings = PlayerSettings(data) else {
                let error = NSError.errorWithMessage(message: "Could not create PlayerSettings object.")
                failure(error)
                return
            }
            success(playerSettings)
        } failure: { error in
            failure(error)
        }.performRequest()
    }
    
    func setSettings(authenticationToken: AuthenticationToken, playerID: String, volumeMode: PlayerSettings.VolumeMode?, volumeScalingFactor: Float?, monoMode: Bool?, wifiDisable: Bool?, success: @escaping (Error?) -> (), failure: @escaping (Error?) -> ()) {
        PlayerSetSettingsNetwork(accessToken: authenticationToken.access_token, playerId: playerID, volumeMode: volumeMode?.rawValue, volumeScalingFactor: volumeScalingFactor, monoMode: monoMode, wifiDisable: wifiDisable) { data in
            if let data = data, let responseError = NSError.errorWithData(data: data) {
                success(responseError)
            } else {
                success(nil)
            }
        } failure: { error in
            failure(error)
        }.performRequest()
    }

}
