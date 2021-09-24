//
//  File.swift
//  
//
//  Created by James Hickman on 2/17/21.
//

import Foundation
import SwiftyJSON

public struct Group: Identifiable, Hashable {
    
    public var id: String
    public var name: String
    public var coordinatorID: String
    public var playbackState: String?
    public var playerIDs: [String]
    
    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let id = json["id"].string,
              let name = json["name"].string,
              let coordinatorID = json["coordinatorId"].string,
              let playerIDs = json["playerIds"].array else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.coordinatorID = coordinatorID
        self.playbackState = json["playbackState"].string
        self.playerIDs = playerIDs.map({ $0.stringValue })
    }

}
