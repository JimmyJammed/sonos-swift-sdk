# Migrating to 2.0

This is a breaking release. Preserve your previous lockfile and use Git history for the callback-based API.

1. Replace old package references with the current SonosSDK product; add SonosSDKUI only when needed.
2. Remove Swinject registration and shared singletons. Construct a SonosClient with explicit token and HTTP providers.
3. Replace callback chains with `let result = try await client.households()` and `do/catch`.
4. Replace SwiftyJSON dictionary access with typed response fields; inspect the networking support matrix for renamed or unsupported endpoints.
5. Remove client secrets and refresh tokens from the app. Run the Server example locally and supply only its opaque app-session credential to BackendTokenProvider.
6. Replace BetterSafariView login with SonosAuthorization. Register the callback scheme and configure matching server/app callbacks.
7. Move UI mutations into main-actor observable state. Explicitly render loading, empty, expired, disconnected and unsupported states.

Old callback/dependency-specific public types are intentionally removed. A failed playback command is not automatically retried: reconcile state before choosing to send another command.

[Historical source](HISTORY.md) retains the previous implementation and notices.
