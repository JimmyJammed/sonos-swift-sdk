import Foundation
@_exported import SonosNetworking

public struct AccessToken: Codable, Sendable {
    public let accessToken: String
    public let expiresAt: Double
    public init(accessToken: String, expiresAt: Double) { self.accessToken = accessToken; self.expiresAt = expiresAt }
    public var isValid: Bool { !accessToken.isEmpty && expiresAt > Date().timeIntervalSince1970 + 30 }
}
public protocol TokenProvider: Sendable {
    func token(forceRefresh: Bool) async throws -> AccessToken
    func logout() async throws
}
public enum AuthenticationError: Error, Sendable { case signedOut, invalidCallback, server(Int), canceled }
public actor FixtureTokenProvider: TokenProvider {
    private var active = true
    public init() {}
    public func token(forceRefresh: Bool = false) throws -> AccessToken {
        guard active else { throw AuthenticationError.signedOut }
        return AccessToken(accessToken: "fixture", expiresAt: Date().timeIntervalSince1970 + 3600)
    }
    public func logout() { active = false }
}
public actor SonosClient {
    private let http: SonosHTTPClient
    private let tokens: any TokenProvider
    public init(tokens: any TokenProvider, http: SonosHTTPClient) { self.tokens = tokens; self.http = http }
    public func perform<Response>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let token = try await tokens.token(forceRefresh: false)
        do { return try await http.send(endpoint, accessToken: token.accessToken) }
        catch NetworkError.http(let status, _) where status == 401 && endpoint.method == "GET" {
            let refreshed = try await tokens.token(forceRefresh: true)
            return try await http.send(endpoint, accessToken: refreshed.accessToken)
        }
    }
    public func households() async throws -> [Household] { try await perform(Endpoints.householdsGetHouseholds()).households ?? [] }
    public func groups(householdID: String) async throws -> Groups { try await perform(Endpoints.groupsGetGroupsHouseholdId(householdId: householdID)) }
    public func favorites(householdID: String) async throws -> FavoritesList { try await perform(Endpoints.favoritesGetFavoritesHouseholdId(householdId: householdID)) }
    public func play(groupID: String) async throws { _ = try await perform(Endpoints.playbackPlayGroupId(groupId: groupID)) }
    public func pause(groupID: String) async throws { _ = try await perform(Endpoints.playbackPauseGroupId(groupId: groupID)) }
    public func volume(groupID: String, value: Int) async throws {
        guard (0...100).contains(value) else { throw NetworkError.invalidConfiguration }
        _ = try await perform(Endpoints.groupVolumeSetVolumeGroupId(groupId: groupID, body: .init(volume: value)))
    }
    public func logout() async throws { try await tokens.logout() }
}

public struct FixtureTransport: HTTPTransport {
    public enum Scenario: String, CaseIterable, Sendable { case normal, empty, disconnected, expired, unsupported }
    private let scenario: Scenario
    public init(scenario: Scenario = .normal) { self.scenario = scenario }
    public func send(_ request: URLRequest) async throws -> HTTPResponse {
        if scenario == .disconnected { throw URLError(.notConnectedToInternet) }
        if scenario == .expired { return HTTPResponse(status: 401) }
        if scenario == .unsupported { return HTTPResponse(status: 403, data: Data(#"{"errorCode":"ERROR_UNSUPPORTED_NAMESPACE"}"#.utf8)) }
        let path = request.url!.path
        let json: String
        if path.hasSuffix("/households") {
            json = scenario == .empty ? #"{"households":[]}"# : #"{"households":[{"id":"home"}]}"#
        } else if path.hasSuffix("/groups") {
            json = #"{"groups":[{"id":"living","name":"Living Room","coordinatorId":"speaker","playbackState":"PLAYBACK_STATE_PAUSED","playerIds":["speaker"]}],"players":[{"id":"speaker","name":"Living Room","capabilities":["PLAYBACK","AUDIO_CLIP"],"websocketUrl":"wss://example.invalid","softwareVersion":"fixture","apiVersion":"1","minApiVersion":"1","deviceIds":["demo"]}]}"#
        } else if path.hasSuffix("/favorites") {
            json = #"{"version":"fixture","items":[{"id":"favorite","name":"Evening Mix"}]}"#
        } else { json = "{}" }
        return HTTPResponse(status: 200, data: Data(json.utf8))
    }
}
