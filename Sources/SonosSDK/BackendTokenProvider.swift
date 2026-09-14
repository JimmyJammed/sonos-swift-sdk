import Foundation

public struct AuthorizationStart: Codable, Sendable {
    public let url: URL
    public let state: String
}
public actor BackendTokenProvider: TokenProvider {
    private let baseURL: URL
    private let sessionToken: String
    private let transport: any HTTPTransport
    private var cached: AccessToken?
    private var pending: Task<AccessToken, Error>?
    private var generation = 0
    private var signedOut = false
    public init(baseURL: URL, sessionToken: String, transport: any HTTPTransport = URLSessionTransport()) throws {
        guard baseURL.scheme == "https" || (["localhost", "127.0.0.1"].contains(baseURL.host ?? "") && baseURL.scheme == "http"), !sessionToken.isEmpty else { throw NetworkError.invalidConfiguration }
        self.baseURL = baseURL; self.sessionToken = sessionToken; self.transport = transport
    }
    public func startAuthorization() async throws -> AuthorizationStart {
        guard !signedOut else { throw AuthenticationError.signedOut }
        return try await request("auth/start", method: "POST")
    }
    private func request<T: Decodable & Sendable>(_ path: String, method: String) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path), timeoutInterval: 15)
        request.httpMethod = method
        request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        let response = try await transport.send(request)
        let data = response.data
        let status = response.status
        guard (200...299).contains(status) else { throw AuthenticationError.server(status) }
        return try JSONDecoder().decode(T.self, from: data)
    }
    public func token(forceRefresh: Bool = false) async throws -> AccessToken {
        guard !signedOut else { throw AuthenticationError.signedOut }
        if !forceRefresh, let cached, cached.isValid { return cached }
        if let pending {
            let current = generation
            let value = try await pending.value
            guard generation == current, !signedOut else { throw AuthenticationError.signedOut }
            return value
        }
        let current = generation
        let task = Task { try await self.request(forceRefresh ? "token/refresh" : "token", method: "POST") as AccessToken }
        pending = task
        do {
            let value = try await task.value
            guard generation == current, !signedOut else { throw AuthenticationError.signedOut }
            guard value.isValid else { throw AuthenticationError.signedOut }
            cached = value; pending = nil
            return value
        } catch {
            if generation == current { pending = nil }
            throw error
        }
    }
    public func logout() async throws {
        signedOut = true; generation += 1; pending?.cancel(); pending = nil; cached = nil
        let _: EmptyResponse = try await request("session", method: "DELETE")
    }
    public static func validateCallback(_ url: URL, expectedURL: URL, state: String) throws {
        guard url.scheme == expectedURL.scheme, url.host == expectedURL.host, url.path == expectedURL.path,
              let parts = URLComponents(url: url, resolvingAgainstBaseURL: false),
              parts.queryItems?.filter({ $0.name == "state" }).count == 1,
              parts.queryItems?.first(where: { $0.name == "state" })?.value == state,
              !state.isEmpty else { throw AuthenticationError.invalidCallback }
    }
}
