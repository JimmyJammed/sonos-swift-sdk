# Architecture

View → main-actor observable DemoModel → SonosClient actor → TokenProvider / injectable HTTPTransport → Sonos HTTPS API.

The Foundation product contains no UI dependency. SonosSDKUI owns only native authorization presentation. The app creates and owns clients, observable state and tasks. FixtureTransport follows the same request path and provides deterministic normal/empty/disconnected/expired/unsupported states.

The server creates authenticated, opaque app sessions. OAuth authorization codes terminate at the server; only a correlation state returns through the app callback. Server-side token exchange stores refresh credentials in memory. The app receives an access token and expiry through its authenticated session. Process restart intentionally invalidates all demo sessions.

This is a local integration example, not a complete production identity service. Production needs user authentication, durable encrypted credential storage, HTTPS ingress, access controls, rate limiting and revocation. Keep that deployment independent of the package.
