//
//  File.swift
//  
//
//  Created by James Hickman on 2/24/21.
//

import Foundation
import SwiftyJSON
import SonosNetworking

struct FavoriteService {
            
    func getFavorites(authenticationToken: AuthenticationToken, householdId: String, success: @escaping ([Favorite]) -> (), failure: @escaping (Error?) -> ()) {
        FavoritesGetNetwork(accessToken: authenticationToken.access_token, householdId: householdId) { data in
            guard let favorites = data.map({ self.decode($0) }) else {
                let error = NSError.errorWithMessage(message: "Could not create Favorites object.")
                failure(error)
                return
            }
            success(favorites)
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func loadFavorite(authenticationToken: AuthenticationToken, groupId: String, favoriteId: String, success: @escaping (Error?) -> (), failure: @escaping (Error?) -> ()) {
        FavoritesLoadNetwork(accessToken: authenticationToken.access_token, groupId: groupId, action: "REPLACE", favoriteId: favoriteId, playOnCompletion: true, playModes: nil) { data in
            guard let data = data else {
                success(nil)
                return
            }
            success(NSError.errorWithData(data: data))
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func subscribe(authenticationToken: AuthenticationToken, householdId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        FavoritesSubscribeNetwork(accessToken: authenticationToken.access_token, householdId: householdId) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    func unsubscribe(authenticationToken: AuthenticationToken, householdId: String, success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        FavoritesUnsubscribeNetwork(accessToken: authenticationToken.access_token, householdId: householdId) { data in
            success()
        } failure: { error in
            failure(error)
        }.performRequest()
    }

    fileprivate func decode(_ data: Any) -> [Favorite] {
        
        let json = JSON(data)
        var favorites = [Favorite]()
        for item in json["items"].arrayValue {
            if let favorite = Favorite(item) {
                favorites.append(favorite)
            }
        }
        return favorites
        
    }
}
