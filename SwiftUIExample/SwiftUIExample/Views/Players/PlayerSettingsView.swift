//
//  PlayerSettingsView.swift
//  SwiftUIExample
//
//  Created by James Hickman on 2/22/21.
//

import SwiftUI
import SonosSDK
import SwiftUIRefresh

struct PlayerSettingsView: View {
    var player: Player
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    private let debouncer = Debouncer(timeInterval: 0.5)

    @State var isLoading = false
    @State var isRefreshing = false

    @State var isErrorAlertPresented = false
    @State var error: Error?

    @State var pickerVolumeModeValue: PlayerSettings.VolumeMode = .variable
    @State var stepperVolumeScalingFactorValue: Float = 1.00
    @State var toggleMonoModeValue: Bool = false
    @State var toggleWifiDisableValue: Bool = false

    @State var playerSettings: PlayerSettings = PlayerSettings() {
        didSet {
            pickerVolumeModeValue = playerSettings.volumeMode
            stepperVolumeScalingFactorValue = playerSettings.volumeScalingFactor
            toggleMonoModeValue = playerSettings.monoMode
            toggleWifiDisableValue = playerSettings.wifiDisable
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
                    // Volume Mode
                    VStack {
                        Text("Volume Mode")
                            .frame(maxWidth: .infinity, alignment: Alignment.leading)
                        Picker(selection: $pickerVolumeModeValue, label: Text("Volume Mode")) {
                            ForEach(PlayerSettings.VolumeMode.allCases) { value in
                                Text(value.rawValue)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: pickerVolumeModeValue, perform: { value in
                            guard pickerVolumeModeValue != playerSettings.volumeMode else { return }

                            isLoading.toggle()
                            setPlayerSettings(volumeMode: value) {
                                isLoading.toggle()
                            }
                        })
                    }
                    .disabled(isRefreshing)

                    // Volume Scaling Factor
                    HStack {
                        Stepper(String(format: "Volume Scaling Factor: %.2f", stepperVolumeScalingFactorValue), value: $stepperVolumeScalingFactorValue, in: 0.01...1.00, step: 0.01) { _ in
                            guard stepperVolumeScalingFactorValue != playerSettings.volumeScalingFactor else { return }
                            debouncer.renewInterval()
                            debouncer.handler = {
                                isLoading.toggle()
                                setPlayerSettings(volumeScalingFactor: stepperVolumeScalingFactorValue) {
                                    isLoading.toggle()
                                }
                            }
                        }
                    }
                    .disabled(isRefreshing)

                    // Mono Mode
                    HStack {
                        Toggle("Mono Mode", isOn: $toggleMonoModeValue)
                            .onChange(of: toggleMonoModeValue) { _ in
                                guard toggleMonoModeValue != playerSettings.monoMode else { return }

                                isLoading.toggle()
                                setPlayerSettings(monoMode: toggleMonoModeValue) {
                                    isLoading.toggle()
                                }
                            }
                    }
                    .disabled(isRefreshing)

                    // Wi-Fi Disabled
                    HStack {
                        Toggle("Wi-Fi Disabled", isOn: $toggleWifiDisableValue)
                            .onChange(of: toggleWifiDisableValue) { _ in
                                guard toggleWifiDisableValue != playerSettings.wifiDisable else { return }

                                isLoading.toggle()
                                setPlayerSettings(wifiDisable: toggleWifiDisableValue) {
                                    isLoading.toggle()
                                }
                            }
                    }
                    .disabled(isRefreshing)
                }
                .pullToRefresh(isShowing: $isRefreshing) {
                    getPlayerSettings(usingCache: false) {
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
            getPlayerSettings {
                isLoading.toggle()
            }
        })
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Oops!"), message: Text(error?.localizedDescription ?? ""), dismissButton: .default(Text("Dismiss")))
        }
    }

    func reloadUI() {
        pickerVolumeModeValue = playerSettings.volumeMode
        stepperVolumeScalingFactorValue = playerSettings.volumeScalingFactor
        toggleMonoModeValue = playerSettings.monoMode
        toggleWifiDisableValue = playerSettings.wifiDisable
    }

    func getPlayerSettings(usingCache: Bool = true, completion: @escaping (() -> Void)) {
        sonosManager.getPlayerSettings(forPlayer: player) { playerSettings in
            self.playerSettings = playerSettings
            completion()
        } failure: { error in
            presentErrorIfNeeded(error)
            completion()
        }
    }

    func setPlayerSettings(volumeMode: PlayerSettings.VolumeMode? = nil, volumeScalingFactor: Float? = nil, monoMode: Bool? = nil, wifiDisable: Bool? = nil, completion: @escaping (() -> Void)) {
        sonosManager.setPlayerSettings(forPlayer: player, volumeMode: volumeMode, volumeScalingFactor: volumeScalingFactor, monoMode: monoMode, wifiDisable: wifiDisable, success: { error in
            presentErrorIfNeeded(error)
            if let volumeMode = volumeMode {
                self.playerSettings.volumeMode = volumeMode
            }
            if let volumeScalingFactor = volumeScalingFactor {
                self.playerSettings.volumeScalingFactor = volumeScalingFactor
            }
            if let monoMode = monoMode {
                self.playerSettings.monoMode = monoMode
            }
            if let wifiDisable = wifiDisable {
                self.playerSettings.wifiDisable = wifiDisable
            }
            completion()
        }, failure: { error in
            presentErrorIfNeeded(error)
            completion()
        })
    }

    func presentErrorIfNeeded(_ error: Error?) {
        guard let error = error else { return }
        self.error = error
        isErrorAlertPresented.toggle()
        reloadUI() // Required to reset properties to correct state
    }

}
