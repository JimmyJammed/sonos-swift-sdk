//
//  PlayerView.swift
//  SonosSDKExample
//
//  Created by James Hickman on 2/20/21.
//

import SwiftUI
import SonosSDK
import SwiftUIRefresh

struct PlayerView: View {
    var player: Player
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    @State var isLoading = false
    @State var isRefreshing = false

    @State var isErrorAlertPresented = false
    @State var error: Error?

    var body: some View {
        List {
            NavigationLink(
                destination: AudioClipView(player: player)) {
                Text("audioClip")
            }
            NavigationLink(
                destination: HomeTheaterView(player: player)) {
                Text("homeTheater")
            }
            NavigationLink(
                destination: PlayerVolumeView(player: player)) {
                Text("playerVolume")
            }
            NavigationLink(
                destination: PlayerSettingsView(player: player)) {
                Text("playerSettings")
            }
        }
        .navigationBarTitle(player.name, displayMode: .large)
    }

}
