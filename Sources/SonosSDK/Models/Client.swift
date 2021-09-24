//
//  File.swift
//  
//
//  Created by James Hickman on 2/8/21.
//

import Foundation

public struct Client: Codable, Equatable {
    
    public var keyName: String
    public var key: String
    public var secret: String
    public var redirectURI: String
    public var callbackURL: String
    
    public init(keyName: String, key: String, secret: String, redirectURI: String, callbackURL: String) {
        self.keyName = keyName
        self.key = key
        self.secret = secret
        self.redirectURI = redirectURI
        self.callbackURL = callbackURL
    }

}
