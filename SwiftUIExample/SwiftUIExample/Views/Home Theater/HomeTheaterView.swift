//
//  HomeTheaterView.swift
//  SwiftUIExample
//
//  Created by James Hickman on 2/22/21.
//

import SwiftUI
import SonosSDK
import SwiftUIRefresh

struct HomeTheaterView: View {
    var player: Player
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    @State var isLoading = false
    @State var isRefreshing = false

    @State var isErrorAlertPresented = false
    @State var error: Error?

    @State var isNightModeEnabled = false
    @State var isEnhanceDialogEnabled = false

    @State var homeTheaterOptions: HomeTheaterOptions = HomeTheaterOptions() {
        didSet {
            isNightModeEnabled = homeTheaterOptions.nightMode
            isEnhanceDialogEnabled = homeTheaterOptions.enhanceDialog
        }
    }

    var body: some View {
        Group {
            if isLoading {
                // Progress View
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                List {
                    // Night Mode
                    HStack {
                        Toggle("Night Mode", isOn: $isNightModeEnabled)
                            .onChange(of: isNightModeEnabled) { value in
                                isLoading.toggle()
                                setNightMode(enabled: value) {
                                    isLoading.toggle()
                                }
                            }
                    }

                    // Enhance Dialog
                    HStack {
                        Toggle("Enhance Dialog", isOn: $isEnhanceDialogEnabled)
                            .onChange(of: isEnhanceDialogEnabled) { value in
                                isLoading.toggle()
                                setEnhanceDialog(enabled: value) {
                                    isLoading.toggle()
                                }
                            }
                    }
                }
                .pullToRefresh(isShowing: $isRefreshing) {
                    getHomeTheaterOptions(usingCache: false) {
                        isRefreshing.toggle()
                    }
                }
                .onChange(of: isRefreshing) { _ in
                    // No-op - This is required due to a bug with `.pullToRefresh` not observing the variable change: https://github.com/siteline/SwiftUIRefresh/issues/15
                }
            }
        }
        .navigationBarTitle(isLoading ? "Loading..." : "Home Theater Options", displayMode: .large)
        .onAppear(perform: {
            isLoading.toggle()
            getHomeTheaterOptions {
                isLoading.toggle()
            }
        })
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Oops!"),
                  message: Text(error?.localizedDescription ?? "Looks like there was an issue communicating with the server. Please try again."),
                  dismissButton: .default(Text("Dismiss")))
        }
    }

    func getHomeTheaterOptions(usingCache: Bool = true, completion: @escaping (() -> Void)) {
        sonosManager.getHomeTheaterOptions(playerId: player.id) { homeTheaterOptions in
            self.homeTheaterOptions = homeTheaterOptions
            completion()
        } failure: { error in
            presentErrorIfNeeded(error)
            completion()
        }
    }

    func setNightMode(enabled: Bool, completion: @escaping (() -> Void)) {
        sonosManager.setNightMode(playerId: player.id, enabled: enabled) { error in
            presentErrorIfNeeded(error)
            self.homeTheaterOptions.nightMode = enabled
            completion()
        } failure: { error in
            presentErrorIfNeeded(error)
            completion()
        }
    }

    func setEnhanceDialog(enabled: Bool, completion: @escaping (() -> Void)) {
        sonosManager.setEnhanceDialog(playerId: player.id, enabled: enabled) { error in
            presentErrorIfNeeded(error)
            self.homeTheaterOptions.enhanceDialog = enabled
            completion()
        } failure: { error in
            if let error = error {
                presentErrorIfNeeded(error)
            }
            completion()
        }
    }

    func reloadUI() {
        isNightModeEnabled = homeTheaterOptions.nightMode
        isEnhanceDialogEnabled = homeTheaterOptions.enhanceDialog
    }

    func presentErrorIfNeeded(_ error: Error?) {
        guard let error = error else { return }
        self.error = error
        isErrorAlertPresented.toggle()
        reloadUI()
    }

}
