//
//  MetadataStatus.swift
//
//
//  Created by Mia Yu on 2023/12/12.
//

import Foundation
import SwiftyJSON

public struct MetadataStatus {
    public var container: Container
    public var currentItem: QueueItem?
    public var nextItem: QueueItem?
    public var playbackSession: PlaybackSession

    init?(_ data: Any) {
        let json = JSON(data)

        guard let containerData = json["container"].dictionary,
              let currentItemData = json["currentItem"].dictionary,
              let nextItemData = json["nextItem"].dictionary,
              let playbackSessionData = json["playbackSession"].dictionary else {
            return nil
        }

        container = Container(containerData)
        currentItem = QueueItem(currentItemData)
        nextItem = QueueItem(nextItemData)
        playbackSession = PlaybackSession(playbackSessionData)
    }
}

public struct Container {
    public var name: String?
    public var type: String?
    public var id: UniversalMusicObjectId?
    public var images: [Any]

    init(_ data: [String: Any]) {
        let json = JSON(data)

        name = json["name"].string
        type = json["type"].string
        if let idData = json["id"].dictionary {
            id = UniversalMusicObjectId(idData)
        }
        images = json["images"].arrayObject ?? []
    }
}

public struct QueueItem {
    public var track: Track?

    init?(_ data: [String: Any]) {
        let json = JSON(data)

        guard let trackData = json["track"].dictionary else {
            return nil
        }

        track = Track(trackData)
    }
}

public struct Track {
    public var type: String
    public var name: String
    public var imageUrl: String
    public var images: [Image]
    public var album: Album
    public var artist: Artist
    public var id: UniversalMusicObjectId
    public var service: Service?
    public var durationMillis: UInt

    init?(_ data: [String: Any]) {
        let json = JSON(data)

        guard let type = json["type"].string,
              let name = json["name"].string,
              let imageUrl = json["imageUrl"].string,
              let imagesData = json["images"].arrayObject,
              let albumData = json["album"].dictionary,
              let artistData = json["artist"].dictionary,
              let idData = json["id"].dictionary,
              let serviceData = json["service"].dictionary,
              let durationMillis = json["durationMillis"].uInt else {
            return nil
        }

        self.type = type
        self.name = name
        self.imageUrl = imageUrl
        images = imagesData.compactMap { Image($0 as? [String: Any] ?? [:]) }
        album = Album(albumData)
        artist = Artist(artistData)
        id = UniversalMusicObjectId(idData)
        service = Service(serviceData)
        self.durationMillis = durationMillis
    }
}

public struct Image {
    public var url: String

    init(_ data: [String: Any]) {
        let json = JSON(data)

        url = json["url"].string ?? ""
    }
}

public struct Album {
    public var name: String

    init(_ data: [String: Any]) {
        let json = JSON(data)

        name = json["name"].string ?? ""
    }
}

public struct Artist {
    public var name: String

    init(_ data: [String: Any]) {
        let json = JSON(data)

        name = json["name"].string ?? ""
    }
}

public struct UniversalMusicObjectId {
    public var serviceId: String
    public var objectId: String

    init(_ data: [String: Any]) {
        let json = JSON(data)

        serviceId = json["serviceId"].string ?? ""
        objectId = json["objectId"].string ?? ""
    }
}

public struct PlaybackSession {
    public var clientId: String
    public var isSuspended: Bool
    public var accountId: String

    init(_ data: [String: Any]) {
        let json = JSON(data)

        clientId = json["clientId"].string ?? ""
        isSuspended = json["isSuspended"].bool ?? false
        accountId = json["accountId"].string ?? ""
    }
}
