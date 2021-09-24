//
//  File.swift
//  
//
//  Created by James Hickman on 2/8/21.
//

import SwiftUI
import BetterSafariView
import Swinject

struct AuthorizationView: ViewModifier {
    @Binding var isPresented: Bool
    var url: URL
    var completion: (Bool) -> Void

    func body(content: Content) -> some View {
        content
        .webAuthenticationSession(isPresented: $isPresented) {
            WebAuthenticationSession(
                url: url,
                callbackURLScheme: "sonos-sdk-example"
            ) { callbackURL, error in
                guard let callbackURL = callbackURL else {
                    completion(false)
                    return
                }
                if let authorization = Authorization(fromURL: callbackURL) {
                    ConfigurationProvider.shared.container.register(Authorization.self) { _ in authorization }
                    let sonosManager = ConfigurationProvider.shared.container.resolve(SonosManager.self)
                    sonosManager?.getAuthenticationToken(success: { token in
                        completion(true)
                    }, failure: { error in
                        completion(false)
                    })
                } else {
                    completion(false)
                }
            }
            .prefersEphemeralWebBrowserSession(false)
        }
    }
    
}

public extension View {
    
    func sonosAuthorizationView(url: URL, isPresented: Binding<Bool>, completion: @escaping (Bool) -> Void) -> some View {
        self.modifier(
            AuthorizationView(isPresented: isPresented, url: url, completion: completion)
        )
    }
    
}
