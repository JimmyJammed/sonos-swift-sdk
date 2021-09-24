//
//  HouseholdDetailsView.swift
//  SonosSDKExample
//
//  Created by James Hickman on 2/17/21.
//

import SwiftUI
import SonosSDK
import SwiftUIRefresh

struct HouseholdDetailsView: View {

    var household: Household
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    @State private var groups: [SonosSDK.Group] = []
    @State private var players: [Player] = []

    @State var isLoading = false
    @State var isRefreshing = false
    @State var isSubscribedToGroups = false
    @State var isSubscribedToFavorites = false

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
                    Section(header: Text("Groups")) {
                        ForEach(groups) { group in
                            NavigationLink(
                                destination: GroupDetailsView(group: group, players: players)) {
                                VStack(alignment: .leading, spacing: 8.0) {
                                    Text(group.name)
                                }
                            }
                        }
                    }
                    Section {
                        // Subscribed to Groups
                        HStack {
                            Toggle("Subscribed to Groups", isOn: $isSubscribedToGroups)
                                .onChange(of: isSubscribedToGroups) { _ in
                                    isLoading.toggle()
                                    if isSubscribedToGroups {
                                        subscribeToGroups {
                                            isLoading.toggle()
                                        }

                                    } else {
                                        unsubscribeToGroups {
                                            isLoading.toggle()
                                        }
                                    }
                                }
                        }
                        .disabled(isRefreshing)
                    }
                    Section {
                        // Favorites
                        NavigationLink(
                            destination: FavoritesView(household: household, groups: groups)) {
                            VStack(alignment: .leading, spacing: 8.0) {
                                Text("Favorites")
                            }
                        }
                        .disabled(isRefreshing)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .pullToRefresh(isShowing: $isRefreshing) {
                    getGroups(usingCache: false, success: { (groups, players) in
                        self.groups = groups
                        self.players = players
                        isRefreshing.toggle()
                    }, failure: { error in
                        isRefreshing.toggle()
                        presentErrorIfNeeded(error)
                    })
                }
                .onChange(of: isRefreshing) { _ in
                    // No-op - This is required due to a bug with `.pullToRefresh` not observing the variable change: https://github.com/siteline/SwiftUIRefresh/issues/15
                }
            }
        }
        .navigationBarTitle(isLoading ? "Loading..." : "Household Details", displayMode: .large)
        .onAppear(perform: {
            isLoading.toggle()
            getGroups(usingCache: false, success: { (groups, players) in
                self.groups = groups
                self.players = players
                isLoading.toggle()
            }, failure: { error in
                isLoading.toggle()
                presentErrorIfNeeded(error)
            })
        })
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Oops!"),
                  message: Text(error?.localizedDescription ?? "Looks like there was an issue communicating with the server. Please try again."),
                  dismissButton: .default(Text("Dismiss")))
        }
    }

    func getGroups(usingCache: Bool = true, success: @escaping (([SonosSDK.Group], [Player]) -> Void), failure: @escaping ((Error?) -> Void)) {
        sonosManager.getGroups(householdId: household.id) { (groups, players) in
            success(groups, players)
        } failure: { error in
            failure(error)
        }
    }

    func subscribeToGroups(completion: @escaping (() -> Void)) {
        self.sonosManager.subscribeToGroups(forHouseholdId: household.id, success: {
            completion()
        }, failure: { error in
            presentErrorIfNeeded(error)
            completion()
        })
    }

    func unsubscribeToGroups(completion: @escaping (() -> Void)) {
        self.sonosManager.unsubscribeToGroups(forHouseholdId: household.id, success: {
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
    }

}
