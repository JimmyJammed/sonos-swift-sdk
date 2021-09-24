//
//  File.swift
//  
//
//  Created by James Hickman on 2/20/21.
//

import Foundation

extension SonosManager {

    public func getPlayerVolume(forPlayer player: Player, success: @escaping (PlayerVolume) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        playerVolumeService.getVolume(authenticationToken: authenticationToken, playerID: player.id, success: { playerVolume in
            success(playerVolume)
        }, failure: failure)
    }
    
    public func setPlayerVolume(forPlayer player: Player, volume: Int, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        playerVolumeService.setVolume(authenticationToken: authenticationToken, playerID: player.id, volume: volume, success: {
            success()
        }, failure: failure)
    }

    public func setPlayerMuted(forPlayer player: Player, muted: Bool, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        playerVolumeService.setMuted(authenticationToken: authenticationToken, playerID: player.id, muted: muted, success: success, failure: failure)
    }

    public func setPlayerRelativeVolume(forPlayer player: Player, relativeVolume: Int, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        playerVolumeService.setRelativeVolume(authenticationToken: authenticationToken, playerID: player.id, relativeVolume: relativeVolume, success: success, failure: failure)
    }

    public func subscribeToPlayerVolume(forPlayer player: Player, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        playerVolumeService.subscribe(authenticationToken: authenticationToken, playerID: player.id, success: success, failure: failure)
    }

    public func unsubscribeToPlayerVolume(forPlayer player: Player, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        playerVolumeService.unsubscribe(authenticationToken: authenticationToken, playerID: player.id, success: success, failure: failure)
    }

}
