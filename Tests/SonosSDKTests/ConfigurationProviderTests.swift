import XCTest
@testable import SonosSDK

final class ConfigurationProviderTests: XCTestCase {
    var configurationProvider: ConfigurationProvider!
    
    struct SonosConfiguration {
        
        static let keyName = "your-sonos-key-name"
        static let key = "your-sonos-developer-key"
        static let secret = "your-sonos-developer-secret"
        static let redirectURI = "sonos-swift-sdk://authorize"
        static let callbackURL = "your-webhook-api-url"

    }
    
    override func setUp() {
        configurationProvider = ConfigurationProvider.shared
    }
    
    func testRegister() {
        XCTAssertNil(configurationProvider.resolve(Client.self))
        let client = Client(keyName: SonosConfiguration.keyName, key: SonosConfiguration.key, secret: SonosConfiguration.secret, redirectURI: SonosConfiguration.redirectURI, callbackURL: SonosConfiguration.callbackURL)
        configurationProvider.register(Client.self, to: client)
        XCTAssertEqual(client, configurationProvider.resolve(Client.self))
    }

    static var allTests = [
        ("testRegister", testRegister),
    ]
}
