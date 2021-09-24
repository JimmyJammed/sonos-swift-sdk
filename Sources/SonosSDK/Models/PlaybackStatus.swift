//
//  File.swift
//
//
//  Created by James Hickman on 2/23/21.
//

import Foundation
import SwiftyJSON

public struct PlaybackStatus {
    
    public var availablePlaybackActions: PlaybackActions
    public var itemId: String?
    public var isDucking: Bool
    public var playbackState: String
    public var playModes: PlayModes
    public var positionMillis: UInt
    public var previousItemId: String?
    public var previousPositionMillis: UInt
    public var queueVersion: String?
    
    init?(_ data: Any) {
        let json = JSON(data)
        
        guard let availablePlaybackActions = json["availablePlaybackActions"].dictionary,
              let isDucking = json["isDucking"].bool,
              let playbackState = json["playbackState"].string,
              let playModes = json["playModes"].dictionary,
              let positionMillis = json["positionMillis"].uInt,
              let previousPositionMillis = json["previousPositionMillis"].uInt else { return nil }

        self.availablePlaybackActions = PlaybackActions(availablePlaybackActions)
        self.itemId = json["itemId"].string
        self.isDucking = isDucking
        self.playbackState = playbackState
        self.playModes = PlayModes(playModes)
        self.positionMillis = positionMillis
        self.previousItemId = json["previousItemId"].string
        self.previousPositionMillis = previousPositionMillis
        self.queueVersion = json["queueVersion"].string
    }

}

public struct PlayModes {
    
    public var shuffle: Bool
    public var repeatOne: Bool
    public var crossfade: Bool
    public var `repeat`: Bool
    
    init(_ data: [String: Any]) {
        let json = JSON(data)
        self.shuffle = json["shuffle"].boolValue
        self.repeatOne = json["repeatOne"].boolValue
        self.crossfade = json["crossfade"].boolValue
        self.repeat = json["repeat"].boolValue
    }
    
}

public struct PlaybackActions {
    
    public var canCrossfade: Bool
    public var canRepeat: Bool
    public var canRepeatOne: Bool
    public var canResume: Bool
    public var canSeek: Bool
    public var canShuffle: Bool
    public var canSkipBack: Bool
    public var canSkipToItem: Bool
    public var limitedSkips: Bool
    public var notifyUserIntent: Bool
    public var pauseAtEndOfQueue: Bool
    public var pauseOnDuck: Bool
    public var pauseTtlSec: Int
    public var playTtlSec: Int
    public var refreshAuthWhilePaused: Bool
    public var showNNextTracks: Int
    public var showNPreviousTracks: Int
    public var skipsRemaining: Int
        
    init(_ data: [String: Any]) {
        let json = JSON(data)
        self.canCrossfade = json["canCrossfade"].boolValue
        self.canRepeat = json["canRepeat"].boolValue
        self.canRepeatOne = json["canRepeatOne"].boolValue
        self.canResume = json["canResume"].boolValue
        self.canSeek = json["canSeek"].boolValue
        self.canShuffle = json["canShuffle"].boolValue
        self.canSkipBack = json["canSkipBack"].boolValue
        self.canSkipToItem = json["canSkipToItem"].boolValue
        self.limitedSkips = json["limitedSkips"].boolValue
        self.notifyUserIntent = json["notifyUserIntent"].boolValue
        self.pauseAtEndOfQueue = json["pauseAtEndOfQueue"].boolValue
        self.pauseOnDuck = json["pauseOnDuck"].boolValue
        self.pauseTtlSec = json["pauseTtlSec"].int ?? 0
        self.playTtlSec = json["playTtlSec"].int ?? 0
        self.refreshAuthWhilePaused = json["refreshAuthWhilePaused"].boolValue
        self.showNNextTracks = json["showNNextTracks"].int ?? 0
        self.showNPreviousTracks = json["showNPreviousTracks"].int ?? 0
        self.skipsRemaining = json["skipsRemaining"].int ?? 0
    }
}
