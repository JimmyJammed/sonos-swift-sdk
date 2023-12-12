//
//  GroupPlaybackMetadataService.swift
//
//
//  Created by Mia Yu on 2023/12/12.
//

import Foundation
import SonosNetworking

struct GroupPlaybackMetadataService {

    func getGroupPlaybackMetadata(token: String,
                                  groupId: String,
                                  success: @escaping ((MetadataStatus) -> ()),
                                  failure: @escaping (Error?) -> ()) {

        PlaybackGetMetadataNetwork(accessToken: token, groupId: groupId) { data in

            guard let data = data,
                  let metadataStatus = MetadataStatus(data) else {
                
                let error = NSError.errorWithMessage(message: "Could not create MetadataStatus object.")
                failure(error)
                return
                
            }

            success(metadataStatus)
            
        } failure: { error in
            
            failure(error)
            
        }.performRequest()
    }
}
