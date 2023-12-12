//
//  SonosManager+GroupPlaybackPlayMode.swift
//
//
//  Created by Mia Yu on 2023/12/8.
//

import Foundation

extension SonosManager {

    public func setGroupPlaybackPlayMode(groupId: String,
                                         playModes: [String: Any],
                                         success: @escaping () -> Void,
                                         failure: @escaping (Error?) -> Void) {

        guard let authenticationToken = authenticationToken else {

            let error = NSError.errorWithMessage(message: "Could not load authentication token.")

            failure(error)

            return

        }

        groupPlaybackPlayModeService.setGroupPlaybackPlayMode(tokenString: authenticationToken.access_token,
                                                              groupId: groupId, playModes: playModes) {
            success()

        } failure: { error in

            failure(error)

        }
    }
}
