//
//  File.swift
//  
//
//  Created by James Hickman on 2/17/21.
//

import Foundation
import SwiftyJSON

public struct Player: Identifiable, Hashable {
    
    public var id: String
    public var name: String
    public var websocketURL: String
    public var softwareVersion: String
    public var apiVersion: String
    public var minApiVersion: String
    public var isUnregistered: Bool
    public var capabilities: [String]
    public var deviceIDs: [String]
    
    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let id = json["id"].string,
              let name = json["name"].string,
              let websocketURL = json["websocketUrl"].string,
              let softwareVersion = json["softwareVersion"].string,
              let apiVersion = json["apiVersion"].string,
              let minApiVersion = json["minApiVersion"].string,
              let isUnregistered = json["isUnregistered"].bool,
              let capabilities = json["capabilities"].array,
              let deviceIDs = json["deviceIds"].array else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.websocketURL = websocketURL
        self.softwareVersion = softwareVersion
        self.apiVersion = apiVersion
        self.minApiVersion = minApiVersion
        self.isUnregistered = isUnregistered
        self.capabilities = capabilities.map({ $0.stringValue })
        self.deviceIDs = deviceIDs.map({ $0.stringValue })
    }

}

public extension Player {
    
    var presentationName: String {
        return name + "()"
    }
}
