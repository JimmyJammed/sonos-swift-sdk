//
//  File.swift
//  
//
//  Created by James Hickman on 2/23/21.
//

import Foundation
import SonosNetworking

struct AudioClipService {
                
    func loadAudioClip(authenticationToken: AuthenticationToken, playerId: String, appId: String, clipType: String?, httpAuthorization: String?, name: String, priority: String?, streamURL: String?, volume: Int?, success: @escaping (AudioClip?, Error?) -> (), failure: @escaping (Error?) -> ()) {
        AudioClipLoadNetwork(accessToken: authenticationToken.access_token, playerId: playerId, appId: appId, clipType: clipType, httpAuthorization: httpAuthorization, name: name, priority: priority, streamUrl: streamURL, volume: volume) { data in
            guard let data = data else {
                success(nil, nil)
                return
            }
            success(AudioClip(data), NSError.errorWithData(data: data))
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func cancelAudioClip(authenticationToken: AuthenticationToken, playerId: String, id: String, success: @escaping (Error?) -> (), failure: @escaping (Error?) -> ()) {
        AudioClipCancelNetwork(accessToken: authenticationToken.access_token, playerId: playerId, id: id) { data in
            if let data = data, let responseError = NSError.errorWithData(data: data) {
                success(responseError)
            } else {
                success(nil)
            }
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func subscribe(authenticationToken: AuthenticationToken, playerId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        AudioClipSubscribeNetwork(accessToken: authenticationToken.access_token, playerId: playerId) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func unsubscribe(authenticationToken: AuthenticationToken, playerId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        AudioClipUnsubscribeNetwork(accessToken: authenticationToken.access_token, playerId: playerId) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

}
