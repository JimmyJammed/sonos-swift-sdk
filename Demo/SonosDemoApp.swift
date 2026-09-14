import SwiftUI
import SonosSDK
import SonosSDKUI

@MainActor @Observable final class DemoModel {
    var households: [Household] = []
    var groups: [SonosNetworking.Group] = []
    var players: [Player] = []
    var favorites: [Favorite] = []
    var message = ""
    var loading = false
    var scenario = FixtureTransport.Scenario.normal
    var client: SonosClient?
    func load() async {
        loading = true; message = ""; households = []; groups = []; players = []; favorites = []
        defer { loading = false }
        do {
            let current = SonosClient(tokens: FixtureTokenProvider(), http: try SonosHTTPClient(transport: FixtureTransport(scenario: scenario)))
            client = current
            households = try await current.households()
            if let id = households.first?.id {
                let result = try await current.groups(householdID: id)
                groups = result.groups ?? []; players = result.players ?? []
                favorites = try await current.favorites(householdID: id).items
            } else { message = "No households. Add speakers to your Sonos account to begin." }
        } catch { message = String(describing: error) }
    }
    func connect(_ provider: BackendTokenProvider, mock: Bool) async {
        loading = true; message = ""; groups = []; players = []; households = []; favorites = []
        defer { loading = false }
        do {
            let current = SonosClient(tokens: provider, http: try SonosHTTPClient(transport: mock ? FixtureTransport() : URLSessionTransport()))
            client = current
            households = try await current.households()
            if let id = households.first?.id {
                let result = try await current.groups(householdID: id)
                groups = result.groups ?? []; players = result.players ?? []
            }
            if let id = households.first?.id {
                favorites = try await current.favorites(householdID: id).items
            }
            message = mock ? "Connected to the local mock session." : "Connected to your Sonos account."
        } catch { message = String(describing: error) }
    }
    func command(_ action: @escaping (SonosClient) async throws -> Void) async {
        guard let client else { return }
        do { try await action(client); message = "Command sent." }
        catch { message = String(describing: error) }
    }
}
@main struct SonosDemoApp: App { var body: some Scene { WindowGroup { SonosDemoView() } } }
struct SonosDemoView: View {
    @State private var model = DemoModel()
    @State private var volume = 25.0
    @State private var backendURL = "http://127.0.0.1:8787"
    @State private var sessionToken = ""
    @State private var mockBackend = true
    @State private var authorization: SonosAuthorization?
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Your rooms, in harmony.").font(.largeTitle.bold())
                    Text("Explore a fictional Sonos household. No account or speaker required.").foregroundStyle(.secondary)
                    Picker("Demo state", selection: $model.scenario) {
                        ForEach(FixtureTransport.Scenario.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    if model.loading { ProgressView("Loading household") }
                    if !model.message.isEmpty { Text(model.message).accessibilityIdentifier("status") }
                }
                ForEach(model.groups, id: \.id) { group in
                    Section(group.name) {
                        Label((group.playbackState ?? "Unknown playback").replacingOccurrences(of: "PLAYBACK_STATE_", with: "").capitalized, systemImage: "speaker.wave.2")
                        HStack {
                            Button("Play") { Task { await model.command { try await $0.play(groupID: group.id) } } }
                            Button("Pause") { Task { await model.command { try await $0.pause(groupID: group.id) } } }
                        }.buttonStyle(.bordered)
                        Slider(value: $volume, in: 0...100, step: 1) { Text("Volume") } onEditingChanged: { editing in
                            if !editing { Task { await model.command { try await $0.volume(groupID: group.id, value: Int(volume)) } } }
                        }
                        Text("Volume \(Int(volume))%")
                    }
                }
                Section("Players and capabilities") {
                    ForEach(model.players, id: \.id) { player in
                        Text(player.name)
                        Text(player.capabilities.map { $0.replacingOccurrences(of: "_", with: " ").capitalized }.joined(separator: ", ")).font(.caption)
                    }
                }
                if !model.favorites.isEmpty { Section("Favorites") { ForEach(model.favorites, id: \.id) { favorite in Label(favorite.name, systemImage: "star") } } }
                Section("Integration") {
                    Text("Run the Server example and paste the session token returned by its /session endpoint. Sonos secrets stay on the server.").font(.footnote)
                    TextField("Backend URL", text: $backendURL)
                    SecureField("Backend session token", text: $sessionToken)
                    Toggle("Use mock Sonos responses", isOn: $mockBackend)
                    Button("Connect Sonos") { Task { await connect() } }.disabled(sessionToken.isEmpty)
                    Button("Log out") { Task { await model.command { try await $0.logout() }; model.groups = []; model.players = []; model.households = []; model.favorites = []; model.client = nil; model.message = "Signed out. Reload to restart the fixture." } }
                    Button("Reload") { Task { await model.load() } }
                }
            }.navigationTitle("Sonos SDK")
            .task(id: model.scenario) { await model.load() }
        }
    }
    @MainActor private func connect() async {
        do {
            guard let url = URL(string: backendURL) else { throw AuthenticationError.invalidCallback }
            let provider = try BackendTokenProvider(baseURL: url, sessionToken: sessionToken)
            #if os(iOS)
            guard let anchor = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap(\.windows).first(where: \.isKeyWindow) else { return }
            #else
            guard let anchor = NSApplication.shared.keyWindow else { return }
            #endif
            let auth = SonosAuthorization(anchor: anchor); authorization = auth
            try await auth.authorize(provider: provider, callbackURL: URL(string: "sonos-demo://authorized")!)
            await model.connect(provider, mock: mockBackend)
            authorization = nil
        } catch { model.message = String(describing: error); authorization = nil }
    }

}
