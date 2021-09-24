//
//  HouseholdListView.swift
//  SonosSDKExample
//
//  Created by James Hickman on 2/7/21.
//

import SwiftUI
import SonosSDK

struct HouseholdListView: View {
    @State private var households: [Household]?

    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

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
                    ForEach(households ?? []) { household in
                        NavigationLink(
                            destination: HouseholdDetailsView(household: household)) {
                            HStack {
                                if let name = household.name {
                                    Text("name: \(name)")
                                } else {
                                    Text("id: \(household.id)")
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
                .pullToRefresh(isShowing: $isRefreshing) {
                    getHouseholds(usingCache: false) {
                        isRefreshing.toggle()
                    }
                }
                .onChange(of: isRefreshing) { _ in
                    // No-op - This is required due to a bug with `.pullToRefresh` not observing the variable change: https://github.com/siteline/SwiftUIRefresh/issues/15
                }
            }
        }
        .navigationBarTitle(isLoading ? "Loading..." : "Households", displayMode: .large)
        .onAppear(perform: {
            isLoading.toggle()
            getHouseholds {
                isLoading.toggle()
            }
        })
        .alert(isPresented: $isErrorAlertPresented) {
            Alert(title: Text("Oops!"),
                  message: Text(error?.localizedDescription ?? "Looks like there was an issue communicating with the server. Please try again."),
                  dismissButton: .default(Text("Dismiss")))
        }
    }

    func getHouseholds(usingCache: Bool = false, completion: @escaping (() -> Void)) {
        sonosManager.getHouseholds { households in
            self.households = households
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
