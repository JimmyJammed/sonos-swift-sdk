# Validation — 2026-09-14

Host: macOS 26.6.2 (25G83), Apple Silicon; Xcode 26.6 (17F113), Swift 6.3.3. Source: this modernization PR; release receipt records the exact merged commit.

- `swift test`: five tests passed, including independent clients, fixture requests/errors, callback mismatch/duplicate state, logout and ten concurrent token requests sharing one backend call.
- `node --test Server/server.test.ts`: two loopback integration tests passed on Node 26.7.0, covering protected session creation, mock authorization, single-use state, token response, logout, canceled authorization and ten concurrent refresh requests sharing one exchange.
- SonosDemo iPhone 17 Pro / iOS 26.5: playback UI test passed.
- SonosDemoMac: generic macOS build passed.
- The demos consume the SPM products and resolve networking from its public reviewed Git commit without sibling checkouts.

Unavailable/unverified: Xcode 27, iOS 18/27, macOS 15/27 runtime, physical devices, real Sonos OAuth/account/speakers, full VoiceOver/keyboard/dynamic-type review and native browser login end-to-end. Mock server tests are not proof of production credential operation. Node 22.18 is the documented minimum but only Node 26.7.0 was executed here.

Run the same local commands on each claimed toolchain/runtime before expanding this matrix. Do not add automatic hosted Actions as a requirement.

Independent temporary SPM executable consumer: built and ran successfully with this package as a dependency. iPhone preview images were captured from the simulator and visually reviewed.

The playback UI test also passed on an iPad Pro 13-inch simulator running iPadOS 26.5. Final macOS demo build passed using a fresh derived-data directory.
