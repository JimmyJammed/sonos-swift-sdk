//
//  File.swift
//  
//
//  Created by James Hickman on 2/20/21.
//

import Foundation
import SwiftyJSON

public struct PlayerVolume {
    
    public var volume: Int = 0
    public var muted: Bool = false
    public var fixed: Bool = false

    public init() { }
    
    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let volume = json["volume"].int,
              let muted = json["muted"].bool,
              let fixed = json["fixed"].bool else {
            return nil
        }
        
        self.volume = volume
        self.muted = muted
        self.fixed = fixed
    }

}
