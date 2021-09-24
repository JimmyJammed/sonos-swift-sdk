//
//  File.swift
//  
//
//  Created by James Hickman on 2/23/21.
//

import Foundation
import SwiftyJSON

public extension AudioClip {
    
    enum ClipType: String, CaseIterable, Identifiable {
        public var id: ClipType { self }

        case chime = "CHIME"
        case custom = "CUSTOM"
    }

    enum Priority: String, CaseIterable, Identifiable {
        public var id: Priority { self }

        case low = "LOW"
        case high = "HIGH"
    }
    
}

public struct AudioClip {
    
    public var id: String = ""
    public var appId: String?
    public var clipType: ClipType?
    public var httpAuthorization: String?
    public var name: String?
    public var priority: Priority?
    public var streamUrl: String?
    public var volume: Int?

    public init() { }
    
    init?(_ data: Any) {
        let json = JSON(data)
        guard let id = json["id"].string else { return nil }
        self.id = id
        self.appId = json["appId"].string
        if let clipType = json["clipType"].string {
            self.clipType = ClipType(rawValue: clipType)
        }
        self.httpAuthorization = json["httpAuthorization"].string
        self.name = json["name"].string
        if let priority = json["priority"].string {
            self.priority = Priority(rawValue: priority)
        }
        self.streamUrl = json["streamUrl"].string
        self.volume = json["volume"].int
    }

}
