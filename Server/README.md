# Local authentication broker

Dependency-free TypeScript executed by Node 22.18+ (tested with Node 26.7.0). No registry packages or hosted deployment required.

```sh
cd Server
cp .env.example .env
# Set DEMO_BOOTSTRAP_TOKEN to a fresh local value; leave SONOS_MOCK=1.
node --env-file=.env server.ts
```

In another terminal, use that value to create an app session:

```sh
curl -X POST http://127.0.0.1:8787/session \
  -H 'Authorization: Bearer YOUR_LOCAL_BOOTSTRAP_VALUE'
```

Paste the returned sessionToken into the demo's Backend session token field. Keep “Use mock Sonos responses” enabled. Connect Sonos opens a native browser session, completes mock authorization through the broker, validates state, and loads fixture responses. The simulator can use 127.0.0.1; a physical device needs a reachable HTTPS backend.

## Real integration

Register a Sonos integration, set SONOS_MOCK=0, SONOS_CLIENT_ID, SONOS_CLIENT_SECRET and the exact registered SONOS_REDIRECT_URI. Configure PUBLIC_ORIGIN for that redirect's server and APP_CALLBACK_URL to match the app's registered callback. Disable mock responses in the demo only for real credentials. The broker binds loopback; use an application-owned HTTPS ingress when needed. See [Sonos authorization](https://docs.sonos.com/docs/authorize).

POST /session authenticates the local operator with a bootstrap secret. POST /auth/start, POST /token, POST /token/refresh and DELETE /session require the resulting Bearer sessionToken. OAuth state is single-use with a five-minute lifetime; sessions expire in eight hours. Refresh operations are serialized per session. No refresh credential is returned to the client. Logout removes the session even when work is in flight.

The shared bootstrap credential is a local setup aid; never distribute it in a production application. Replace session creation with your authenticated user service, encrypt persistent secrets, enforce tenant isolation and deploy behind HTTPS/rate limiting. This example deliberately uses ephemeral memory storage.

```sh
node --test server.test.ts
```

Tests use only a loopback mock server. They do not contact Sonos or validate a real account.
