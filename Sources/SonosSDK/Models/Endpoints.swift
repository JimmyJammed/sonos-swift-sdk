//
//  Endpoints.swift
//  SonosSDK
//
//  Created by James Hickman on 2/5/21.
//

import Foundation

struct SonosAPIHost {
    
    static let authorization = "api.sonos.com"
    static let control = "api.ws.sonos.com"
    static let music = "sonos.com"

}

struct SonosAuthorizationAPIPath {
    
    static let authorizationCode = "login/v3/oauth"
    static let token = "login/v3/oauth/access"
    static let control = "control/api/v1"
}

struct SonosMusicAPIPath {
    
    static let services = "/Services/1.1"
    
}

struct SonosControlAPIPath {
    
    static let players = "control/api/v1/players"

}

struct SonosControlAPIQuery {
    
    static let playerVolume = "/playerVolume"
    static let homeTheaterOptions = "/homeTheater/options"

}
