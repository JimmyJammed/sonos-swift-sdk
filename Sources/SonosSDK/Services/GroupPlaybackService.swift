//
//  File.swift
//
//
//  Created by James Hickman on 2/17/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct GroupPlaybackService {
            
    func getGroupPlaybackStatus(authenticationToken: AuthenticationToken, groupId: String, success: @escaping (PlaybackStatus) -> (), failure: @escaping (Error?) -> ()) {
        PlaybackGetStatusNetwork(accessToken: authenticationToken.access_token, groupId: groupId) { data in
            guard let data = data,
                  let playbackStatus = PlaybackStatus(data) else {
                let error = NSError.errorWithMessage(message: "Could not create PlaybackStatus object.")
                failure(error)
                return
            }
            success(playbackStatus)
        } failure: { error in
            failure(error)
        }.performRequest()
    }

}
