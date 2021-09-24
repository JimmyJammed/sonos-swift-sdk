//
//  GroupPlaybackStatusView.swift
//  SonosSDKExample
//
//  Created by James Hickman on 2/17/21.
//

import SwiftUI
import SonosSDK
import SwiftUIRefresh

struct GroupPlaybackStatusView: View {

    var groupId: String
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    @State private var playbackStatus: PlaybackStatus?

    @State var isLoading = false
    @State var isRefreshing = false

    @State var isErrorAlertPresented = false
    @State var error: Error?

    var body: some View {
        Group {
            if isLoading {
                // Progress View
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                List {
                    Section(header: Text("State")) {
                        Text("itemId: \(playbackStatus?.itemId ?? "")")
                        Text("isDucking: \(playbackStatus?.isDucking ?? false ? "true" : "false")")
                        Text("playbackState: \(playbackStatus?.playbackState ?? "")")
                        Text("positionMillis: \(String(playbackStatus?.positionMillis ?? 0))")
                        Text("previousItemId: \(playbackStatus?.previousItemId ?? "")")
                        Text("previousPositionMillis: \(String(playbackStatus?.previousPositionMillis ?? 0))")
                        Text("queueVersion: \(playbackStatus?.queueVersion ?? "")")
                    }

                    Section(header: Text("Available Playback Actions")) {
                        Group { // List can only handle 10 items at a time so requires this fixs
                            Text("canCrossfade: \(playbackStatus?.availablePlaybackActions.canCrossfade ?? false ? "true" : "false")")
                            Text("canRepeat: \(playbackStatus?.availablePlaybackActions.canRepeat ?? false ? "true" : "false")")
                            Text("canRepeatOne: \(playbackStatus?.availablePlaybackActions.canRepeatOne ?? false ? "true" : "false")")
                            Text("canResume: \(playbackStatus?.availablePlaybackActions.canResume ?? false ? "true" : "false")")
                            Text("canSeek: \(playbackStatus?.availablePlaybackActions.canSeek ?? false ? "true" : "false")")
                            Text("canShuffle: \(playbackStatus?.availablePlaybackActions.canShuffle ?? false ? "true" : "false")")
                            Text("canSkipBack: \(playbackStatus?.availablePlaybackActions.canSkipBack ?? false ? "true" : "false")")
                            Text("canSkipToItem: \(playbackStatus?.availablePlaybackActions.canSkipToItem ?? false ? "true" : "false")")
                            Text("limitedSkips: \(playbackStatus?.availablePlaybackActions.limitedSkips ?? false ? "true" : "false")")
                            Text("notifyUserIntent: \(playbackStatus?.availablePlaybackActions.notifyUserIntent ?? false ? "true" : "false")")
                        }
                        Group {
                            Text("pauseAtEndOfQueue: \(playbackStatus?.availablePlaybackActions.pauseAtEndOfQueue ?? false ? "true" : "false")")
                            Text("pauseOnDuck: \(playbackStatus?.availablePlaybackActions.pauseOnDuck ?? false ? "true" : "false")")
                            Text("pauseTtlSec: \(String(playbackStatus?.availablePlaybackActions.pauseTtlSec ?? 0))")
                            Text("playTtlSec: \(String(playbackStatus?.availablePlaybackActions.playTtlSec ?? 0))")
                            Text("refreshAuthWhilePaused: \(playbackStatus?.availablePlaybackActions.refreshAuthWhilePaused ?? false ? "true" : "false")")
                            Text("showNNextTracks: \(String(playbackStatus?.availablePlaybackActions.showNNextTracks ?? 0))")
                            Text("showNPreviousTracks: \(String(playbackStatus?.availablePlaybackActions.showNPreviousTracks ?? 0))")
                            Text("skipsRemaining: \(String(playbackStatus?.availablePlaybackActions.skipsRemaining ?? 0))")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .pullToRefresh(isShowing: $isRefreshing) {
                    getPlaybackStatus(usingCache: false) {
                        isRefreshing.toggle()
                    }
                }
                .onChange(of: isRefreshing) { _ in
                    // No-op - This is required due to a bug with `.pullToRefresh` not observing the variable change: https://github.com/siteline/SwiftUIRefresh/issues/15
                }
            }
        }
        .navigationBarTitle(isLoading ? "Loading..." : "Group Playback Status", displayMode: .large)
        .onAppear(perform: {
            isLoading.toggle()
            getPlaybackStatus(usingCache: false) {
                isLoading.toggle()
            }
        })
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Oops!"),
                  message: Text(error?.localizedDescription ?? "Looks like there was an issue communicating with the server. Please try again."),
                  dismissButton: .default(Text("Dismiss")))
        }
    }

    func getPlaybackStatus(usingCache: Bool = true, completion: @escaping (() -> Void)) {
        sonosManager.getGroupPlaybackStatus(groupId: groupId) { playbackStatus in
            self.playbackStatus = playbackStatus
            completion()
        } failure: { error in
            presentErrorIfNeeded(error)
            completion()
        }
    }

    func presentErrorIfNeeded(_ error: Error?) {
        guard let error = error else { return }
        self.error = error
        isErrorAlertPresented.toggle()
    }

}
