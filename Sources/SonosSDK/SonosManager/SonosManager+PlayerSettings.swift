//
//  File.swift
//  
//
//  Created by James Hickman on 2/22/21.
//

import Foundation
import SonosNetworking

extension SonosManager {

    public func getPlayerSettings(forPlayer player: Player, success: @escaping (PlayerSettings) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        playerSettingsService.getSettings(authenticationToken: authenticationToken, playerID: player.id, success: { playerSettings in
            success(playerSettings)
        }, failure: failure)
    }
    
    public func setPlayerSettings(forPlayer player: Player, volumeMode: PlayerSettings.VolumeMode?, volumeScalingFactor: Float?, monoMode: Bool?, wifiDisable: Bool?, success: @escaping (Error?) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }
        
        playerSettingsService.setSettings(authenticationToken: authenticationToken, playerID: player.id, volumeMode: volumeMode, volumeScalingFactor: volumeScalingFactor, monoMode: monoMode, wifiDisable: wifiDisable, success: success, failure: failure)
    }

}
