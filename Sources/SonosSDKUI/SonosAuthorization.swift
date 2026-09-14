import AuthenticationServices
import SonosSDK
import SwiftUI

@MainActor public final class SonosAuthorization: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var active = false
    private var session: ASWebAuthenticationSession?
    private var continuation: CheckedContinuation<Void, Error>?
    private let anchor: ASPresentationAnchor
    public init(anchor: ASPresentationAnchor) { self.anchor = anchor }
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor { anchor }
    public func authorize(provider: BackendTokenProvider, callbackURL: URL) async throws {
        guard !active else { throw AuthenticationError.canceled }
        active = true
        defer { active = false }
        let start = try await provider.startAuthorization()
        try Task.checkCancellation()
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                guard !Task.isCancelled else { continuation.resume(throwing: CancellationError()); return }
                self.continuation = continuation
                let auth = ASWebAuthenticationSession(url: start.url, callbackURLScheme: callbackURL.scheme) { [weak self] url, error in
                    Task { @MainActor in
                        guard let self else { return }
                        do {
                            if let error { throw error }
                            guard let url else { throw AuthenticationError.invalidCallback }
                            try BackendTokenProvider.validateCallback(url, expectedURL: callbackURL, state: start.state)
                            self.finish(.success(()))
                        } catch { self.finish(.failure(error)) }
                    }
                }
                session = auth; auth.presentationContextProvider = self
                if !auth.start() { finish(.failure(AuthenticationError.canceled)) }
            }
        } onCancel: {
            Task { @MainActor in
                self.session?.cancel()
                self.finish(.failure(CancellationError()))
            }
        }
    }
    private func finish(_ result: Result<Void, Error>) {
        let current = continuation; continuation = nil; session = nil
        current?.resume(with: result)
    }
}
