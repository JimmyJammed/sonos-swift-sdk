//
//  FavoritesView.swift
//  SwiftUIExample
//
//  Created by James Hickman on 3/24/21.
//

import SwiftUI
import SonosSDK
import SwiftUIRefresh

struct FavoritesView: View {

    var household: Household
    var groups: [SonosSDK.Group]
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    @State private var favorites: [Favorite] = []

    @State private var showingActionSheet = false
    @State private var selectedFavorite: Favorite?

    @State var isLoading = false
    @State var isRefreshing = false
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
                    Section(header: Text("Favorites")) {
                        ForEach(favorites) { favorite in
                            Button(action: {
                                selectedFavorite = favorite
                                showingActionSheet.toggle()
                            }, label: {
                                HStack(alignment: .center) {
                                    if let imageUrl = favorite.imageUrl {
                                        LazyImage(url: imageUrl.absoluteString)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40)
                                    }
                                    VStack(alignment: .leading, spacing: 8.0) {
                                        Text(favorite.name)
                                        Text(favorite.description)
                                            .font(Font.caption)
                                    }
                                }
                            })
                            .actionSheet(isPresented: $showingActionSheet) {
                                var buttons: [Alert.Button] = groups.enumerated().map { _, group in
                                    ActionSheet.Button.default(Text(group.name), action: {
                                        guard let selectedFavorite = selectedFavorite else { return }
                                        isLoading.toggle()
                                        loadFavorite(favoriteId: selectedFavorite.id, groupId: group.id, success: { error in
                                            presentErrorIfNeeded(error)
                                            isLoading.toggle()
                                        }, failure: { error in
                                            isLoading.toggle()
                                            presentErrorIfNeeded(error)
                                        })
                                    })
                                }
                                buttons.append(ActionSheet.Button.cancel())
                                return ActionSheet(title: Text("Play on"), message: Text("Select a player"), buttons: buttons)
                            }
                        }
                    }
                    Section {
                        // Subscribed to Favorites
                        HStack {
                            Toggle("Subscribed to Favorites", isOn: $isSubscribedToFavorites)
                                .onChange(of: isSubscribedToFavorites) { _ in
                                    isLoading.toggle()
                                    if isSubscribedToFavorites {
                                        subscribeToFavorites {
                                            isLoading.toggle()
                                        }

                                    } else {
                                        unsubscribeToFavorites {
                                            isLoading.toggle()
                                        }
                                    }
                                }
                        }
                        .disabled(isRefreshing)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .pullToRefresh(isShowing: $isRefreshing) {
                    getFavorites(usingCache: false, success: { favorites in
                        self.favorites = favorites
                        isLoading.toggle()
                    }, failure: { error in
                        isLoading.toggle()
                        presentErrorIfNeeded(error)
                    })
                }
                .onChange(of: isRefreshing) { _ in
                    // No-op - This is required due to a bug with `.pullToRefresh` not observing the variable change: https://github.com/siteline/SwiftUIRefresh/issues/15
                }
            }
        }
        .navigationBarTitle(isLoading ? "Loading..." : "Favorites", displayMode: .large)
        .onAppear(perform: {
            isLoading.toggle()
            getFavorites(usingCache: false, success: { favorites in
                self.favorites = favorites
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

    func getFavorites(usingCache: Bool = true, success: @escaping (([Favorite]) -> Void), failure: @escaping (Error?) -> Void) {
        sonosManager.getFavorites(householdId: household.id) { favorites in
            success(favorites)
        } failure: { error in
            failure(error)
        }
    }

    func loadFavorite(favoriteId: String, groupId: String, success: @escaping (Error?) -> Void, failure: @escaping (Error?) -> Void) {
        sonosManager.loadFavorite(groupId: groupId, favoriteId: favoriteId, success: success, failure: failure)
    }

    func subscribeToFavorites(completion: @escaping (() -> Void)) {
        self.sonosManager.subscribeToFavorites(forHouseholdId: household.id, success: {
            completion()
        }, failure: { error in
            presentErrorIfNeeded(error)
            completion()
        })
    }

    func unsubscribeToFavorites(completion: @escaping (() -> Void)) {
        self.sonosManager.unsubscribeToFavorites(forHouseholdId: household.id, success: {
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
