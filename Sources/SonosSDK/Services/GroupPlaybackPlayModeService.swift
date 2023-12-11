//
//  GroupPlaybackPlayModeService.swift
//
//
//  Created by Mia Yu on 2023/12/8.
//

import Foundation
import SonosNetworking

struct GroupPlaybackPlayModeService {

    func getGroupPlaybackPlayMode(tokenString: String,
                                  groupId: String,
                                  playModes: [String:Any],
                                  success: @escaping (() -> ()),
                                  failure: @escaping (Error?) -> ()) {

        PlaybackSetPlayModesNetwork(accessToken: tokenString,
                                    groupId: groupId,
                                    playModes: playModes) { data in
            success()

        } failure: { error in

            failure(error)

        }.performRequest()
    }
}
