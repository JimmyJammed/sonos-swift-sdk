//
//  File.swift
//  
//
//  Created by James Hickman on 2/5/21.
//

import Foundation
import SwiftUI
import Swinject

public class SonosManager: ObservableObject {
    
    // MARK: - Public Vars
    
    @Published public var isAuthenticated: Bool = false

    public var authorizationUrl: URL? {
        let urlString = "https://api.sonos.com/login/v3/oauth?client_id=\(client.key)&response_type=code&state=state_test&scope=playback-control-all&redirect_uri=\(client.redirectURI)"
        return URL(string: urlString)
    }

    // MARK: - Init
    
    public init(keyName: String, key: String, secret: String, redirectURI: String, callbackURL: String) {
        self.client = Client(keyName: keyName, key: key, secret: secret, redirectURI: redirectURI, callbackURL: callbackURL)
        configureDependencies()
    }

    // MARK: - Public Functions
                    
    // MARK: - Internal Vars

    let container = ConfigurationProvider.shared.container

    var client: Client

    var authenticationToken: AuthenticationToken? {
        didSet {
            isAuthenticated = !(authenticationToken?.isExpired ?? true)
        }
    }

    var encodedClientKey: String? {
        let encodedKeys = (client.key + ":" + client.secret).base64encoded
        return encodedKeys
    }

    // MARK: Services
    
    lazy var authenticationTokenService: AuthenticationTokenService = {
        return AuthenticationTokenService()
    }()

    lazy var authenticationRefreshTokenService: AuthenticationRefreshTokenService = {
        return AuthenticationRefreshTokenService()
    }()

    lazy var householdService: HouseholdService = {
        return HouseholdService()
    }()

    lazy var groupService: GroupService = {
        return GroupService()
    }()

    lazy var groupPlaybackService: GroupPlaybackService = {
        return GroupPlaybackService()
    }()

    lazy var groupVolumeService: GroupVolumeService = {
        return GroupVolumeService()
    }()

    lazy var playerService: PlayerService = {
        return PlayerService()
    }()

    lazy var playerVolumeService: PlayerVolumeService = {
        return PlayerVolumeService()
    }()

    lazy var homeTheaterService: HomeTheaterService = {
        return HomeTheaterService()
    }()

    lazy var playerSettingsService: PlayerSettingsService = {
        return PlayerSettingsService()
    }()

    lazy var audioClipService: AudioClipService = {
        return AudioClipService()
    }()

    lazy var favoriteService: FavoriteService = {
        return FavoriteService()
    }()

    // MARK: Internal Functions
    
    func configureDependencies() {
        let container = ConfigurationProvider.shared.container
        
        container.register(SonosManager.self) { _ in self }
    }

}
