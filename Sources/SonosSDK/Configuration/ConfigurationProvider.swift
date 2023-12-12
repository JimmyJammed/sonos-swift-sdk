//
//  File.swift
//  
//
//  Created by James Hickman on 2/9/21.
//

import Foundation
import Swinject

class ConfigurationProvider {

    // Currently using Swinject
    let container = Swinject.Container()

    // Singleton
    static let shared = ConfigurationProvider()

    // Hidden initializer
    private init() {}

    // MARK: - Bind / Resolve

    func register<T>(_ interface: T.Type, to assembly: T) {
        container.register(interface) { _ in assembly }
    }

    func resolve<T>(_ interface: T.Type) -> T! {
        return container.resolve(interface)
    }

}
