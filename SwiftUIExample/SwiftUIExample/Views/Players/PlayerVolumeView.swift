//
//  PlayerVolumeView.swift
//  SonosSDKExample
//
//  Created by James Hickman on 2/20/21.
//

import SwiftUI
import SonosSDK
import SwiftUIRefresh
import MediaPlayer

struct PlayerVolumeView: View {

    var player: Player
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    private let debouncer = Debouncer(timeInterval: 0.5)

    @State var nightModeVolumeLimit: Int = 25
    @State var nightModeTimeDelay: Int = 10

    @State var volume: Double = 0.00

    @State var isLoading = false
    @State var isRefreshing = false

    @State var isMuted = false
    @State var isFixed = false
    @State var isSubscribed = false

    @State var isNightModeRunning = false

    @State var isErrorAlertPresented = false
    @State var error: Error?

    @State var sliderValue: Double = 0.0
    @State var stepperValue: Int = 0

    var body: some View {
        Group {
            if isLoading {
                // Progress View
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                List {
                    Section(header: Text("Volume Controls")) {
                        // Volume
                        VStack {
                            Text("Player Volume: \(Int(volume*100))")
                                .font(Font.headline)
                            Slider(value: $volume,
                                   in: 0.00...1.00) { editing in
                                    if !editing {
                                        setPlayerVolume(volume: volume)
                                    }
                                }
                        }
                        .disabled(isRefreshing)

                        // Change Volume (stepper)
                        HStack {
                            Text("Change Volume")
                                .foregroundColor(Color.theme)
                            Spacer()
                            Stepper("") {
                                guard volume < 1 else { return }
                                volume += 0.01
                                debouncer.renewInterval()
                                debouncer.handler = {
                                    setPlayerVolume(volume: volume)
                                }
                            } onDecrement: {
                                guard volume > 0 else { return }
                                volume -= 0.01
                                debouncer.renewInterval()
                                debouncer.handler = {
                                    setPlayerVolume(volume: volume)
                                }
                            }
                        }
                        .disabled(isRefreshing)

                        // Muted
                        HStack {
                            Toggle("Muted", isOn: $isMuted)
                                .onChange(of: isMuted) { value in
                                    setPlayerMuted(muted: value)
                                }
                        }
                        .disabled(isRefreshing)

                        // Subscribed
                        HStack {
                            Toggle("Subscribed", isOn: $isSubscribed)
                                .onChange(of: isSubscribed) { _ in
                                    if isSubscribed {
                                        subscribe()

                                    } else {
                                        unsubscribe()
                                    }
                                }
                        }
                        .disabled(isRefreshing)
                    }

                    Section(header: Text("Night Mode")) {
                        HStack {
                            Text("Volume Limit")
                            Spacer()
                            TextField("25", value: $nightModeVolumeLimit, format: .number)
                                .frame(width: 50.0)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            Text("Volume Change Delay")
                            Spacer()
                            TextField("10", value: $nightModeTimeDelay, format: .number)
                                .frame(width: 50.0)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            Button {
                                guard isNightModeRunning == false && volume > Double(nightModeVolumeLimit/100) else { return }
                                isNightModeRunning = true
                                runNightMode {
                                    isNightModeRunning = false
                                }
                            } label: {
                                HStack {
                                    Text(isNightModeRunning ? "Running Night Mode..." : "Run Night Mode")
                                    Spacer()
                                    ProgressView().isVisible($isNightModeRunning)
                                }
                            }
                                .disabled(isNightModeRunning || volume <= Double(nightModeVolumeLimit)/100)

                        }
                    }
                }
                .pullToRefresh(isShowing: $isRefreshing) {
                    getPlayerVolume(usingCache: false) {
                        isRefreshing.toggle()
                    }
                }
            }
        }
        .navigationBarTitle(isLoading ? "Loading..." : player.name, displayMode: .large)
        .onAppear(perform: {
            isLoading.toggle()
            getPlayerVolume {
                isLoading.toggle()
            }
        })
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Oops!"),
                  message: Text(error?.localizedDescription ?? "Looks like there was an issue communicating with the server. Please try again."),
                  dismissButton: .default(Text("Dismiss")))
        }
//        .onTapGesture {
//            resignFirstResponder()
//        }
    }

    func getPlayerVolume(usingCache: Bool = true, completion: @escaping (() -> Void)) {
        sonosManager.getPlayerVolume(forPlayer: player) { playerVolume in
            volume = Double(playerVolume.volume)/100
            isMuted = playerVolume.muted
            isFixed = playerVolume.fixed
            completion()
        } failure: { error in
            presentErrorIfNeeded(error)
            completion()
        }
    }

    func setPlayerVolume(volume: Double, completion: (() -> Void)? = nil) {
        let oldValue = self.volume
        sonosManager.setPlayerVolume(forPlayer: player, volume: Int(volume*100)) {
            completion?()
        } failure: { error in
            self.volume = oldValue
            presentErrorIfNeeded(error)
            completion?()
        }
    }

    func setPlayerMuted(muted: Bool, completion: (() -> Void)? = nil) {
        let oldValue = self.isMuted
        self.sonosManager.setPlayerMuted(forPlayer: player, muted: muted, success: {
            completion?()
        }, failure: { error in
            self.isMuted = oldValue
            presentErrorIfNeeded(error)
            completion?()
        })
    }

    func setRelativeVolume(value: Double, completion: ((Error?) -> Void)? = nil) {
        let oldValue = volume
        self.sonosManager.setPlayerRelativeVolume(forPlayer: player, relativeVolume: Int(value), success: {
            completion?(nil)
        }, failure: { error in
            volume = oldValue
            presentErrorIfNeeded(error)
            completion?(error)
        })
    }

    func subscribe(completion: (() -> Void)? = nil) {
        self.sonosManager.subscribeToPlayerVolume(forPlayer: player, success: {
            completion?()
        }, failure: { error in
            presentErrorIfNeeded(error)
            completion?()
        })
    }

    func unsubscribe(completion: (() -> Void)? = nil) {
        self.sonosManager.unsubscribeToPlayerVolume(forPlayer: player, success: {
            completion?()
        }, failure: { error in
            presentErrorIfNeeded(error)
            completion?()
        })
    }

    func presentErrorIfNeeded(_ error: Error?) {
        guard let error = error else { return }
        self.error = error
        isErrorAlertPresented.toggle()
    }

    func runNightMode(completion: (() -> Void)? = nil) {
        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "backgroundTaskRunNightMode") {
            debugPrint("[DEBUG] Nightmode took to long to run in the background.")
        }
        isNightModeRunning = true
        DispatchQueue.global(qos: .background).async {
            let oldValue = volume
            volume -= 0.01
            setRelativeVolume(value: -1) { error in
                guard error == nil else {
                    volume = oldValue
                    presentErrorIfNeeded(error)

                    if backgroundTaskIdentifier != UIBackgroundTaskIdentifier.invalid {
                        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                    }
                    completion?()
                    return
                }
                debugPrint("[DEBUG] Nightmode set volume to: \(volume)")
                if volume > Double(nightModeVolumeLimit)/100 {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + Double(nightModeTimeDelay)) {
                        runNightMode(completion: completion)
                    }
                } else {
                    debugPrint("[DEBUG] Nightmode finished running!")
                    if backgroundTaskIdentifier != UIBackgroundTaskIdentifier.invalid {
                        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                    }
                    completion?()
                }
            }
        }
    }
}
