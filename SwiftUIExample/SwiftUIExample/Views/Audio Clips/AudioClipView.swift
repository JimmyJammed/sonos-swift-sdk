//
//  AudioClipView.swift
//  SwiftUIExample
//
//  Created by James Hickman on 2/23/21.
//

import Foundation
import SwiftUI
import SonosSDK

struct AudioClipView: View {
    var player: Player
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    @State var audioClip: AudioClip?
    @State var isLoading = false
    @State var isSubscribed = false

    @State var isErrorAlertPresented = false
    @State var error: Error?

    @State var textFieldAppIDValue: String = ""
    @State var textFieldNameValue: String = ""
    @State var textFieldHTTPAuthorizationValue: String = ""
    @State var textFieldStreamURLValue: String = ""
    @State var textFieldVolumeValue: String = ""

    @State var pickerClipTypeValue: AudioClip.ClipType = .chime
    @State var pickerPriorityValue: AudioClip.Priority = .low

    var body: some View {
        Group {
            if isLoading {
                // Progress View
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                List {
                    // appID *Required
                    HStack {
                        Text("App ID:")
                        TextField("com.my.app", text: $textFieldAppIDValue)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }

                    // clipName *Required
                    HStack {
                        Text("Name:")
                        TextField("My Sound Clip", text: $textFieldNameValue)
                            .disableAutocorrection(true)
                    }

                    // clipType
                    HStack {
                        Text("Clip Type")
                            .frame(maxWidth: .infinity, alignment: Alignment.leading)
                        Picker(selection: $pickerClipTypeValue, label: Text("Clip Type")) {
                            ForEach(AudioClip.ClipType.allCases) { value in
                                Text(value.rawValue)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // httpAuthorization
                    HStack {
                        Text("HTTP Authorization:")
                        TextField("<HTTP AUTHORIZATION STRING>", text: $textFieldHTTPAuthorizationValue)
                            .disableAutocorrection(true)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                    }

                    // priority
                    HStack {
                        Text("Priority")
                            .frame(maxWidth: .infinity, alignment: Alignment.leading)
                        Picker(selection: $pickerPriorityValue, label: Text("Priority")) {
                            ForEach(AudioClip.Priority.allCases) { value in
                                Text(value.rawValue)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // streamUrl
                    HStack {
                        Text("Stream URL:")
                        TextField("http://www.moviesoundclips.net/effects/animals/wolf-howls.mp3", text: $textFieldStreamURLValue, onCommit: {
                            pickerClipTypeValue = textFieldStreamURLValue == "" ? .chime : .custom
                        })
                            .disableAutocorrection(true)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                    }

                    // volume
                    HStack {
                        Text("Volume:")
                        TextField("20", text: $textFieldVolumeValue)
                            .disableAutocorrection(true)
                            .textContentType(.telephoneNumber)
                    }

                    // Subscribed
                    HStack {
                        Toggle("Subscribed", isOn: $isSubscribed)
                            .onChange(of: isSubscribed) { _ in
                                isLoading.toggle()
                                if isSubscribed {
                                    subscribe {
                                        isLoading.toggle()
                                    }

                                } else {
                                    unsubscribe {
                                        isLoading.toggle()
                                    }
                                }
                            }
                    }

                    // Send Button
                    Button(action: {
                        loadAudioClip()
                    },
                    label: {
                        HStack(alignment: .center, spacing: 8) {
                            Text("Send Audio Clip")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(10.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10.0)
                                .stroke(lineWidth: 2.0)
                        )
                        .foregroundColor(isLoading ? Color.textDisabled : Color.theme)
                    })

                    // Cancel Button
                    Button(action: {
                        cancelAudioClip()
                    }, label: {
                        HStack(alignment: .center, spacing: 8) {
                            Text("Cancel Audio Clip")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(10.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10.0)
                                .stroke(lineWidth: 2.0)
                        )
                        .foregroundColor(isLoading ? Color.textDisabled : Color.theme)
                    })
                }
            }
        }
        .navigationBarTitle(isLoading ? "Loading..." : "Audio Clip", displayMode: .large)
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Oops!"),
                  message: Text(error?.localizedDescription ?? "Looks like there was an issue communicating with the server. Please try again."),
                  dismissButton: .default(Text("Dismiss")))
        }
//        .onTapGesture {
//            resignFirstResponder()
//        }
    }

    func loadAudioClip() {
        isLoading.toggle()
        let httpAuthorization = textFieldHTTPAuthorizationValue != "" ? textFieldHTTPAuthorizationValue : nil
        let streamUrl = textFieldStreamURLValue != "" ? textFieldStreamURLValue : nil
        let volume = textFieldVolumeValue != "" ? Int(textFieldVolumeValue) : nil
        sonosManager.loadAudioClip(playerId: player.id,
                                   appId: textFieldAppIDValue,
                                   clipType: pickerClipTypeValue.rawValue,
                                   httpAuthorization: httpAuthorization,
                                   name: textFieldNameValue,
                                   priority: pickerPriorityValue.rawValue,
                                   streamUrl: streamUrl,
                                   volume: volume) { (audioClip, error) in
            isLoading.toggle()
            presentErrorIfNeeded(error)
            self.audioClip = audioClip
        } failure: { error in
            isLoading.toggle()
            presentErrorIfNeeded(error)
        }
    }

    func subscribe(completion: @escaping (() -> Void)) {
        self.sonosManager.subscribeToAudioClip(playerId: player.id, success: {
            completion()
        }, failure: { error in
            presentErrorIfNeeded(error)
            completion()
        })
    }

    func unsubscribe(completion: @escaping (() -> Void)) {
        self.sonosManager.unsubscribeToAudioClip(playerId: player.id, success: {
            completion()
        }, failure: { error in
            presentErrorIfNeeded(error)
            completion()
        })
    }

    func cancelAudioClip() {
        guard let id = audioClip?.id else { return }
        isLoading.toggle()
        sonosManager.cancelAudioClip(playerId: player.id, id: id) { error in
            isLoading.toggle()
            presentErrorIfNeeded(error)
        } failure: { error in
            isLoading.toggle()
            presentErrorIfNeeded(error)
        }

    }

    func presentErrorIfNeeded(_ error: Error?) {
        guard let error = error else { return }
        self.error = error
        isErrorAlertPresented.toggle()
    }

}
