import Foundation
import Testing
@testable import SonosSDK

@Test func fixtureHouseholdsAndGroups() async throws {
    let client = SonosClient(tokens: FixtureTokenProvider(), http: try SonosHTTPClient(transport: FixtureTransport()))
    #expect(try await client.households().first?.id == "home")
    #expect(try await client.groups(householdID: "home").groups?.first?.name == "Living Room")
    try await client.play(groupID: "living")
    try await client.pause(groupID: "living")
    try await client.volume(groupID: "living", value: 25)
    await #expect(throws: NetworkError.self) { try await client.volume(groupID: "living", value: 101) }
}
@Test func independentSessionsAndLogout() async throws {
    let first = SonosClient(tokens: FixtureTokenProvider(), http: try SonosHTTPClient(transport: FixtureTransport()))
    let second = SonosClient(tokens: FixtureTokenProvider(), http: try SonosHTTPClient(transport: FixtureTransport()))
    try await first.logout()
    await #expect(throws: AuthenticationError.self) { _ = try await first.households() }
    #expect(try await second.households().count == 1)
}
@Test func callbacksRejectMismatchAndDuplicateState() throws {
    let expected = URL(string: "sonos-demo://authorized")!
    try BackendTokenProvider.validateCallback(URL(string:"sonos-demo://authorized?state=ok")!, expectedURL: expected, state:"ok")
    for url in ["other://authorized?state=ok", "sonos-demo://wrong?state=ok", "sonos-demo://authorized?state=bad", "sonos-demo://authorized?state=ok&state=ok"] {
        #expect(throws: AuthenticationError.self) { try BackendTokenProvider.validateCallback(URL(string:url)!, expectedURL:expected,state:"ok") }
    }
}
@Test func fixtureFailures() async throws {
    let empty = SonosClient(tokens: FixtureTokenProvider(), http: try SonosHTTPClient(transport: FixtureTransport(scenario: .empty)))
    #expect(try await empty.households().isEmpty)
    for scenario in [FixtureTransport.Scenario.expired, .unsupported] {
        let client = SonosClient(tokens: FixtureTokenProvider(), http: try SonosHTTPClient(transport: FixtureTransport(scenario: scenario)))
        await #expect(throws: NetworkError.self) { _ = try await client.households() }
    }
}

actor BackendStub: HTTPTransport {
    var count = 0
    func send(_ request: URLRequest) async throws -> HTTPResponse {
        if request.httpMethod == "DELETE" { return HTTPResponse(status: 200, data: Data("{}".utf8)) }
        count += 1
        try await Task.sleep(for: .milliseconds(20))
        let token = AccessToken(accessToken: "shared", expiresAt: Date().timeIntervalSince1970 + 3600)
        return HTTPResponse(status: 200, data: try JSONEncoder().encode(token))
    }
}
@Test func concurrentTokenRequestsShareRefresh() async throws {
    let stub = BackendStub()
    let provider = try BackendTokenProvider(baseURL: URL(string:"https://example.invalid")!, sessionToken:"session", transport:stub)
    try await withThrowingTaskGroup(of: AccessToken.self) { group in
        for _ in 0..<10 { group.addTask { try await provider.token() } }
        for try await value in group { #expect(value.accessToken == "shared") }
    }
    #expect(await stub.count == 1)
    _ = try await provider.token()
    #expect(await stub.count == 1)
    try await provider.logout()
    await #expect(throws: AuthenticationError.self) { _ = try await provider.token() }
}
