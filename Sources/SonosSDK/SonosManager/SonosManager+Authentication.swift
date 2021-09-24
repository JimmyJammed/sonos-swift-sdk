//
//  File.swift
//  
//
//  Created by James Hickman on 2/11/21.
//

import Foundation

extension SonosManager {
    
    private static let authenticationTokenUserDefaultsKey = "AuthenticationTokenUserDefaultsKey_authenticationToken"

    // MARK: - Public Vars
    
    public var cachedToken: AuthenticationToken? {
        guard authenticationToken == nil else { return authenticationToken }
        guard let tokenData = UserDefaults.standard.object(forKey: SonosManager.authenticationTokenUserDefaultsKey) as? Data,
              let token = try? JSONDecoder().decode(AuthenticationToken.self, from: tokenData) else { return nil }
        return token
    }
  
    // MARK: - Public Functions

    public func authenticate(success: @escaping (AuthenticationToken) -> (), failure: @escaping (Error?) -> ()) {
        if let token = cachedToken {
            if token.isExpired { // Cached token has expired
                refreshAuthenticationToken(token: token, success: success, failure: failure)
            } else {
                self.authenticationToken = token // Cached token is valid
                success(token)
            }
        } else { // No cached token
            getAuthenticationToken(success: success, failure: failure)
        }
    }
    
    public func logout() {
        deleteToken()
        ConfigurationProvider.shared.container.removeAll() // Remove all dependency objects
        configureDependencies() // Re-initialize all dependency objects
    }

    // MARK: - Internal Functions

    func getAuthenticationToken(success: @escaping (AuthenticationToken) -> (), failure: @escaping (Error?) -> ()) {
        guard let authorization = ConfigurationProvider.shared.container.resolve(Authorization.self) else {
            let error = NSError.errorWithMessage(message: "Authorization is required before requesting an Authentication Token.")
            failure(error)
            return
        }
        guard let encodedKeys = encodedClientKey else {
            let error = NSError.errorWithMessage(message: "Could not encode client key.")
            failure(error)
            return
        }

        authenticationTokenService.getAuthenticationToken(authorization: authorization, encodedKeys: encodedKeys, redirectURI: client.redirectURI, success: { token in
            self.saveToken(token)
            success(token)
        }, failure: failure)
    }

    func refreshAuthenticationToken(token: AuthenticationToken, success: @escaping (AuthenticationToken) -> (), failure: @escaping (Error?) -> ()) {
        guard let encodedKeys = encodedClientKey else {
            let error = NSError.errorWithMessage(message: "Could not encode client key.")
            failure(error)
            return
        }

        authenticationRefreshTokenService.refreshAuthenticationToken(token: token, encodedKeys: encodedKeys, success: { token in
            self.saveToken(token)
            success(token)
        }, failure: { error in
            self.deleteToken() // Delete bad cached token
            failure(error)
        })
    }

    // MARK: - Private Functions

    private func saveToken(_ token: AuthenticationToken) {
        self.authenticationToken = token
        container.register(AuthenticationToken.self) { _ in token }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(token) {
            UserDefaults.standard.set(encoded, forKey: SonosManager.authenticationTokenUserDefaultsKey)
        }
    }

    private func deleteToken() {
        UserDefaults.standard.removeObject(forKey: SonosManager.authenticationTokenUserDefaultsKey)
        authenticationToken = nil
    }

}
