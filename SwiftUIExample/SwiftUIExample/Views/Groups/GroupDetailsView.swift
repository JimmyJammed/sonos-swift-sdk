//
//  GroupDetailsView.swift
//  SonosSDKExample
//
//  Created by James Hickman on 3/21/21.
//

import SwiftUI
import SonosSDK
import SwiftUIRefresh

struct GroupDetailsView: View {
    var group: SonosSDK.Group
    var players: [Player]
    var sonosManager: SonosManager = ConfigurationProvider.shared.resolve(SonosManager.self)

    @State var availableMembers: [Player] = []
    @State var groupMembers: [Player] = []

    @State var membersToAdd: [Player] = []
    @State var membersToRemove: [Player] = []

    @State var isLoading = false
    @State var isRefreshing = false
    @State var isSubscribed = false
    @State var editMode: EditMode = .inactive

    @State var isErrorAlertPresented = false
    @State var error: Error?

    var body: some View {
        List {
            Section(header: Text("Group Members")) {
                ForEach(groupMembers) { player in
                    VStack(alignment: .leading, spacing: 8.0) {
                        HStack {
                            if editMode == .active {
                                Image(systemName: "minus.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        remove(player)
                                    }
                                    .padding(.trailing, 12)
                                    .transition(AnyTransition.opacity.combined(with: .move(edge: .leading)))
                                    .animation(.spring(), value: 2)
                            }
                            NavigationLink(
                                destination: PlayerView(player: player)) {
                                Text(player.name)
                            }
                            .disabled(editMode == .active)
                        }
                    }
                }
            }

            Section(header: Text("Available Players to Add")) {
                ForEach(availableMembers) { player in
                    VStack(alignment: .leading, spacing: 8.0) {
                        HStack {
                            if editMode == .active {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.green)
                                    .onTapGesture {
                                        add(player)
                                    }
                                    .padding(.trailing, 12)
                                    .transition(AnyTransition.opacity.combined(with: .move(edge: .leading)))
                                    .animation(.spring(), value: 2)
                            }
                            NavigationLink(
                                destination: PlayerView(player: player)) {
                                Text(player.name)
                            }
                            .disabled(editMode == .active)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(isLoading ? "Loading..." : "Group Details", displayMode: .large)
        .navigationBarItems(trailing: EditButton())
        .environment(\.editMode, $editMode)
        .listStyle(InsetGroupedListStyle())
        .onAppear(perform: {
            groupMembers = getMembers(for: group)
            availableMembers = getAvailableMembers(for: group)
        })
    }

    func getMembers(for: SonosSDK.Group) -> [Player] {
        return sonosManager.getGroupMembers(group: group, players: players)
    }

    func getAvailableMembers(for: SonosSDK.Group) -> [Player] {
        let groupMembers = Set(getMembers(for: group))
        let allMembers = Set(players)
        return Array(allMembers.symmetricDifference(groupMembers))
    }

    func add(_ player: Player) {
        if let index = availableMembers.firstIndex(of: player) {
            availableMembers.remove(at: index)
            groupMembers.append(player)
            membersToAdd.append(player)

            sonosManager.modifyGroupMembers(groupId: group.id, playerIdsToAdd: [player.id], playerIdsToRemove: []) { group, error in
                if let error = error {
                    presentErrorIfNeeded(error)
                    if let group = group {
                        groupMembers = getMembers(for: group)
                        availableMembers = getAvailableMembers(for: group)
                    } else {
                        availableMembers.append(player)
                        groupMembers.remove(at: index)
                    }
                }
            } failure: { error in
                presentErrorIfNeeded(error)
                availableMembers.append(player)
                groupMembers.remove(at: index)
            }

        }
    }

    func remove(_ player: Player) {
        if let index = groupMembers.firstIndex(of: player) {
            groupMembers.remove(at: index)
            availableMembers.append(player)
            membersToRemove.append(player)
        }
    }

    func delete(at offsets: IndexSet) {
        groupMembers.remove(atOffsets: offsets)
    }

    func presentErrorIfNeeded(_ error: Error?) {
        guard let error = error else { return }
        self.error = error
        isErrorAlertPresented.toggle()
    }

}
