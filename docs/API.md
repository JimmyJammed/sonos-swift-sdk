# API and support

`SonosClient` is an actor. Construct each client with its own TokenProvider and SonosHTTPClient; there is no global dependency container.

| Method | Behavior |
|---|---|
| households() | Authenticated household inventory |
| groups(householdID:) | Groups and players with advertised capabilities |
| favorites(householdID:) | Typed FavoritesList |
| play(groupID:), pause(groupID:) | Playback commands, never automatically replayed |
| volume(groupID:value:) | Validates 0...100 before sending |
| perform(endpoint) | Access all typed SonosNetworking Endpoints |
| logout() | Invalidate local credentials and backend session |

TokenProvider exposes asynchronous token(forceRefresh:) and logout(). AccessToken carries an expiry in Unix seconds. BackendTokenProvider caches valid tokens, shares in-flight refresh work, and prevents an in-flight result from reviving a logged-out session. A failed GET with HTTP 401 gets one forced refresh; mutation requests do not replay automatically.

SonosSDKUI supplies SonosAuthorization with an explicit presentation anchor. It owns ASWebAuthenticationSession, handles cancellation, and checks callback scheme/host/path/state. Register your callback URL scheme in the app.

HTTP errors, malformed responses and authentication states are thrown rather than collapsed into empty values. Consult the networking package's endpoint support matrix; advertising a capability does not guarantee account authorization. Event subscriptions require an application-owned event receiver; this SDK does not provide a hosted callback service.
