//
//  File.swift
//  
//
//  Created by James Hickman on 2/23/21.
//

import Foundation
import SonosNetworking

extension SonosManager {
    
    public func loadAudioClip(playerId: String, appId: String, clipType: String?, httpAuthorization: String?, name: String, priority: String?, streamUrl: String?, volume: Int?, success: @escaping (AudioClip?, Error?) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        audioClipService.loadAudioClip(authenticationToken: authenticationToken, playerId: playerId, appId: appId, clipType: clipType, httpAuthorization: httpAuthorization, name: name, priority: priority, streamURL: streamUrl, volume: volume, success: success, failure: failure)
    }

    public func cancelAudioClip(playerId: String, id: String, success: @escaping (Error?) -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        audioClipService.cancelAudioClip(authenticationToken: authenticationToken, playerId: playerId, id: id, success: success, failure: failure)
    }

    public func subscribeToAudioClip(playerId: String, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        audioClipService.subscribe(authenticationToken: authenticationToken, playerId: playerId, success: success, failure: failure)
    }

    public func unsubscribeToAudioClip(playerId: String, success: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        guard let authenticationToken = authenticationToken else {
            let error = NSError.errorWithMessage(message: "Could not load authentication token.")
            failure(error)
            return
        }

        audioClipService.unsubscribe(authenticationToken: authenticationToken, playerId: playerId, success: success, failure: failure)
    }

}
