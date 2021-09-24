//
//  ExampleListView.swift
//  SonosSDKExample
//
//  Created by James Hickman on 2/5/21.
//

import SwiftUI
import SonosSDK
import BetterSafariView
import Swinject

struct ExampleListView: View {
    @State var isLoading = false

    @State var showAuthorizationView = false
    @State var showHouseholds = false

    @State var showAlertView = false
    @State var alertTitle: String = ""
    @State var alertText: String = ""

    @State var showAuthorizationErrorAlertView = false

    @ObservedObject var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    // Progress View
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    List {
                        // Authorization
                        if sonosManager.isAuthenticated {
                            // Households
                            NavigationLink(destination: HouseholdListView(), isActive: $showHouseholds) {
                                Text("Households")
                            }.onTapGesture {
                                showHouseholds.toggle()
                            }
                        } else {
                            HStack {
                                Text("Authorize")
                                    .foregroundColor(Color.theme)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isLoading.toggle()
                                showAuthorizationView.toggle()
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Sonos SDK", displayMode: .large)
            .toolbar {
                if sonosManager.isAuthenticated {
                    Button("Logout") {
                        sonosManager.logout()
                    }
                }
            }
        }
        .onAppear {
            isLoading.toggle()
            sonosManager.authenticate { _ in
                isLoading.toggle()
            } failure: { _ in
                isLoading.toggle()
            }
        }
        .sonosAuthorizationView(url: sonosManager.authorizationUrl!, isPresented: $showAuthorizationView, completion: { isAuthenticated in
            isLoading.toggle()
            if !isAuthenticated {
                alertTitle = "Authorization Status"
                alertText = "Oops! Looks like there was a problem authorizing. Please try again."
                showAlertView.toggle()
            }
        })
        .alert(isPresented: $showAlertView) {
            Alert(title: Text(alertTitle), message: Text(alertText), dismissButton: .default(Text("Dismiss")))
        }
    }

}
