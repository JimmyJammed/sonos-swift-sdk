//
//  File.swift
//  
//
//  Created by James Hickman on 2/22/21.
//

import Foundation
import SwiftyJSON

public extension PlayerSettings {
    
    enum VolumeMode: String, CaseIterable, Equatable, Identifiable {
        public var id: VolumeMode { self }
        
        case variable = "VARIABLE"
        case fixed = "FIXED"
        case passthrough = "PASS_THROUGH"
    }

}

public struct PlayerSettings {
    
    public var volumeMode: VolumeMode = .variable
    public var volumeScalingFactor: Float = 1.0
    public var monoMode: Bool = false
    public var wifiDisable: Bool = false

    public init() { }

    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let volumeModeString = json["volumeMode"].string, let volumeMode = VolumeMode(rawValue: volumeModeString),
              let volumeScalingFactor = json["volumeScalingFactor"].float,
              let monoMode = json["monoMode"].bool,
              let wifiDisable = json["wifiDisable"].bool
              else { return nil }
        
        self.volumeMode = volumeMode
        self.volumeScalingFactor = volumeScalingFactor
        self.monoMode = monoMode
        self.wifiDisable = wifiDisable
    }

}
