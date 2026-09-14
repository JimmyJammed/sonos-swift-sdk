# Troubleshooting

- No account needed: leave the fixture state selected; server setup is optional.
- Backend 401: obtain a new app session, then authorize it. Restarting the server clears sessions.
- Callback mismatch: match the registered app scheme, host/path and server APP_CALLBACK_URL. Never bypass state validation.
- Browser canceled: return to the demo and retry Connect Sonos; cancellation is recoverable.
- Network 403/unsupported: check the player's capabilities and the Sonos support matrix.
- No Xcode 27/runtime: record the unavailable check rather than treating a build on another SDK as runtime validation.
- Package resolution: networking is pinned to a public reviewed commit. Use File → Packages → Resolve Package Versions after removing old references.
